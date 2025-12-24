import SwiftUI

struct ArticleDetailView: View {
	@ObservedObject var viewModel: ArticleDetailViewModel
	let offlineStore: OfflineStore

	@State private var isSaved = false
	@State private var isToggling = false

	init(viewModel: ArticleDetailViewModel, offlineStore: OfflineStore = NoopOfflineStore()) {
		self.viewModel = viewModel
		self.offlineStore = offlineStore
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				Text(viewModel.article.title)
					.font(.title)
					.fontWeight(.semibold)
					.accessibilityIdentifier("detail_title")

				if let series = viewModel.article.seriesBadge {
					Text(series)
						.font(.caption2.weight(.semibold))
						.padding(.horizontal, 10)
						.padding(.vertical, 6)
						.background(Color.blue.opacity(0.12))
						.foregroundColor(.blue)
						.clipShape(Capsule())
				}

				Text(viewModel.formattedDate)
					.font(.subheadline)
					.foregroundColor(.secondary)
					.accessibilityIdentifier("detail_date")

				if !viewModel.article.tags.isEmpty {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 8) {
							ForEach(viewModel.article.tags, id: \.self) { tag in
								NavigationLink {
									TagFeedView(tag: tag)
								} label: {
									Text(tag)
										.font(.caption)
										.padding(.horizontal, 10)
										.padding(.vertical, 6)
										.background(Color(.systemGray6))
										.foregroundColor(.primary)
										.clipShape(Capsule())
								}
								.buttonStyle(.plain)
							}
						}
						.padding(.vertical, 4)
					}
				}

				Divider()

				Text(viewModel.attributedContent)
					.font(.body)
					.accessibilityIdentifier("detail_content")
			}
			.padding()
		}
		.navigationTitle("Detail")
		.navigationBarTitleDisplayMode(.inline)
		.accessibilityElement(children: .contain)
		.accessibilityLabel("Article detail for \(viewModel.article.title)")
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(action: toggleSaved) {
					Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
				}
				.disabled(isToggling)
				.accessibilityIdentifier("offline_save_button")
				.accessibilityLabel(isSaved ? "Saved for offline" : "Save for offline")
			}
		}
		.task {
			await loadSavedState()
		}
	}

	private func loadSavedState() async {
		isSaved = await offlineStore.isSaved(articleID: viewModel.article.id)
	}

	private func toggleSaved() {
		guard !isToggling else { return }
		isToggling = true

		Task {
			defer { isToggling = false }
			if isSaved {
				try? await offlineStore.delete(articleID: viewModel.article.id)
				isSaved = false
			} else {
				try? await offlineStore.save(article: viewModel.article)
				isSaved = true
			}
		}
	}
}

// MARK: - Previews
#Preview {
	let sample = Article.previewSamples().first ?? Article(
		id: "placeholder",
		title: "Sample Title",
		excerpt: "",
		contentHTML: "<p>Sample body</p>",
		publishedAt: Date(),
		url: ""
	)

	NavigationStack {
		ArticleDetailView(viewModel: ArticleDetailViewModel(article: sample))
	}
}

#Preview("Missing Content") {
	let empty = Article(
		id: "empty",
		title: "Draft without body",
		excerpt: "",
		contentHTML: "",
		publishedAt: Date(),
		url: "",
		author: nil,
		imageURL: nil,
		tags: [],
		readingTimeMinutes: nil
	)

	NavigationStack {
		ArticleDetailView(viewModel: ArticleDetailViewModel(article: empty))
	}
}

#Preview("Long Content") {
	let longBody = String(repeating: "<p>Long paragraph content.</p>", count: 20)
	let long = Article(
		id: "long",
		title: "In-depth: Beacon chain economics",
		excerpt: "A deep look at incentives.",
		contentHTML: longBody,
		publishedAt: Date(),
		url: "https://example.com/long",
		author: "Researcher",
		imageURL: nil,
		tags: ["Research"],
		readingTimeMinutes: 18
	)

	NavigationStack {
		ArticleDetailView(viewModel: ArticleDetailViewModel(article: long))
	}
}

