import SwiftUI

struct HomeFeedView: View {
    @StateObject private var viewModel: ArticleViewModel

    init(viewModel: ArticleViewModel = ArticleViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.articles.isEmpty {
                ProgressView("Loading articles…")
            } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                VStack(spacing: 12) {
                    Text(error).foregroundColor(.red)
                    Button("Retry") {
                        Task { await viewModel.loadArticles() }
                    }
                }
            } else {
                List(viewModel.articles) { article in
                    NavigationLink(value: article) {
                        ArticleRowView(article: article)
                    }
                }
                .navigationDestination(for: Article.self) { article in
                    ArticleDetailView(viewModel: ArticleDetailViewModel(article: article))
                }
            }
        }
        .navigationTitle("Etherworld")
        .task {
            await viewModel.loadArticles()
        }
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        HomeFeedView(viewModel: ArticleViewModel(service: MockArticleService()))
    }
}
