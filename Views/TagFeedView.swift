import SwiftUI

struct TagFeedView: View {
    @StateObject private var viewModel: TagFeedViewModel

    init(tag: String) {
        _viewModel = StateObject(wrappedValue: TagFeedViewModel(tag: tag))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.articles.isEmpty {
                ProgressView("Loading \(viewModel.title)...")
            } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                VStack(spacing: 12) {
                    Text(error).foregroundColor(.red)
                    Button("Retry") {
                        Task { await viewModel.load() }
                    }
                }
            } else if viewModel.articles.isEmpty {
                Text("No articles found for \(viewModel.title)")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.articles) { article in
                            NavigationLink(value: article) {
                                ArticleRowView(article: article)
                            }
                            .buttonStyle(.plain)
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(viewModel: ArticleDetailViewModel(article: article))
        }
    }
}
