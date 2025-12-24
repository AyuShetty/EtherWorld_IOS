import SwiftUI

struct HomeFeedView: View {
	@StateObject private var viewModel: ArticleViewModel
	@State private var searchText = ""

	init(viewModel: ArticleViewModel = ArticleViewModel()) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}

	var body: some View {
		Group {
			if viewModel.isLoading && viewModel.articles.isEmpty {
				loadingView
			} else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
				errorView(message: error)
			} else if viewModel.articles.isEmpty {
				emptyStateView
			} else {
				feedView
			}
		}
		.navigationTitle("Etherworld")
		.navigationBarTitleDisplayMode(.large)
		.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search articles")
		.task { await viewModel.loadArticles() }
		.refreshable { await viewModel.loadArticles() }
	}

	private var filteredArticles: [Article] {
		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !query.isEmpty else { return viewModel.articles }
		let lower = query.lowercased()
		return viewModel.articles.filter { article in
			article.title.lowercased().contains(lower)
				|| article.excerpt.lowercased().contains(lower)
				|| article.tags.contains(where: { $0.lowercased().contains(lower) })
		}
	}

	private var feedView: some View {
		ScrollView {
			LazyVStack(spacing: 16) {
				if let first = filteredArticles.first {
					NavigationLink(value: first) {
						HeroArticleCard(article: first)
					}
					.buttonStyle(.plain)
					.accessibilityIdentifier("article_hero_\(first.id)")
				}

				if filteredArticles.count > 1 {
					ForEach(filteredArticles.dropFirst()) { article in
						NavigationLink(value: article) {
							ArticleRowView(article: article)
						}
						.buttonStyle(.plain)
						.accessibilityIdentifier("article_row_\(article.id)")
					}
				} else if filteredArticles.isEmpty {
					Text("No results for \"\(searchText)\"")
						.font(.subheadline)
						.foregroundColor(.secondary)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.top, 12)
				}
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
		}
		.navigationDestination(for: Article.self) { article in
			ArticleDetailView(viewModel: ArticleDetailViewModel(article: article))
		}
		.accessibilityLabel("Article list")
	}

	private var loadingView: some View {
		VStack(spacing: 12) {
			ProgressView()
				.progressViewStyle(.circular)
				.accessibilityLabel("Loading articles")
			Text("Loading Etherworld articles...")
				.font(.body)
				.foregroundColor(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	private func errorView(message: String) -> some View {
		VStack(spacing: 12) {
			Text("Unable to load articles")
				.font(.headline)
				.foregroundColor(.red)
			Text(message)
				.font(.subheadline)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
			Button(action: { Task { await viewModel.loadArticles() } }) {
				Label("Retry", systemImage: "arrow.clockwise")
			}
			.buttonStyle(.borderedProminent)
			.accessibilityIdentifier("retry_button")
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.accessibilityLabel("Error state")
	}

	private var emptyStateView: some View {
		VStack(spacing: 12) {
			Text("No articles yet")
				.font(.headline)
			Text("Check back soon for the latest Etherworld updates.")
				.font(.subheadline)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
			Button(action: { Task { await viewModel.loadArticles() } }) {
				Label("Refresh", systemImage: "arrow.clockwise")
			}
			.buttonStyle(.bordered)
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.accessibilityLabel("Empty state")
	}
}

// MARK: - Previews
#Preview {
	NavigationStack {
		HomeFeedView(viewModel: ArticleViewModel(service: MockArticleService()))
	}
}

#Preview("Loading State") {
	NavigationStack {
		HomeFeedView(viewModel: .loadingPreview())
	}
}

#Preview("Empty State") {
	NavigationStack {
		HomeFeedView(viewModel: .emptyPreview())
	}
}

#Preview("Error State") {
	NavigationStack {
		HomeFeedView(viewModel: .errorPreview())
	}
}

private extension ArticleViewModel {
	static func loadingPreview() -> ArticleViewModel {
		ArticleViewModel.preview(isLoading: true)
	}

	static func emptyPreview() -> ArticleViewModel {
		ArticleViewModel.preview(articles: [], isLoading: false, errorMessage: nil)
	}

	static func errorPreview() -> ArticleViewModel {
		ArticleViewModel.preview(errorMessage: "Network unavailable.")
	}
}

// MARK: - Hero Card
private struct HeroArticleCard: View {
	let article: Article

	var body: some View {
		ZStack(alignment: .bottomLeading) {
			ArticleAsyncImage(url: article.imageURL)
				.frame(height: 260)
				.frame(maxWidth: .infinity)
				.clipped()
				.cornerRadius(16)
				.overlay(
					LinearGradient(
						colors: [Color.black.opacity(0.6), Color.black.opacity(0.2)],
						startPoint: .bottom,
						endPoint: .top
					)
					.cornerRadius(16)
				)

			VStack(alignment: .leading, spacing: 8) {
				if let date = article.publishedAtFormatted {
					Text(date)
						.font(.caption)
						.fontWeight(.semibold)
						.foregroundColor(.white.opacity(0.9))
						.padding(.horizontal, 10)
						.padding(.vertical, 6)
						.background(Color.white.opacity(0.16))
						.clipShape(Capsule())
				}

				Text(article.title)
					.font(.title2.weight(.bold))
					.foregroundColor(.white)
					.lineLimit(3)

				if !article.excerpt.isEmpty {
					Text(article.excerpt)
						.font(.subheadline)
						.foregroundColor(.white.opacity(0.85))
						.lineLimit(2)
				}
			}
			.padding(16)
		}
		.shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
		.accessibilityElement(children: .combine)
		.accessibilityLabel("Featured article: \(article.title)")
	}
}

private struct ArticleAsyncImage: View {
	let url: URL?

	var body: some View {
		if let url = url {
			AsyncImage(url: url) { phase in
				switch phase {
				case .empty:
					placeholder
				case .success(let image):
					image
						.resizable()
						.scaledToFill()
				case .failure:
					placeholder
				@unknown default:
					placeholder
				}
			}
		} else {
			placeholder
		}
	}

	private var placeholder: some View {
		ZStack {
			LinearGradient(
				colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.15)],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			Image(systemName: "photo")
				.foregroundColor(.white.opacity(0.6))
		}
	}
}

private extension Article {
	var publishedAtFormatted: String? {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter.string(from: publishedAt)
	}
}

