import Foundation

@MainActor
final class ArticleViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: ArticleService

    init(service: ArticleService = MockArticleService()) {
        self.service = service
    }

    func loadArticles() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await service.fetchArticles()
            articles = fetched.sorted { $0.publishedAt > $1.publishedAt }
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load articles."
        }
    }
}
