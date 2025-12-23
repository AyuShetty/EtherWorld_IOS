import SwiftUI

struct HomeFeedView: View {
    @StateObject private var viewModel: ArticleViewModel

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
                listView
            }
        }
        .navigationTitle("Etherworld")
        .task {
            await viewModel.loadArticles()
        }
    }

    private var listView: some View {
        List(viewModel.articles) { article in
            NavigationLink(value: article) {
                ArticleRowView(article: article)
            }
            .accessibilityIdentifier("article_row_\(article.id)")
        }
        .listStyle(.inset)
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
            Text("Loading Etherworld articles…")
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
            Button(action: {
                Task { await viewModel.loadArticles() }
            }) {
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
            Button(action: {
                Task { await viewModel.loadArticles() }
            }) {
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
