import Foundation

@MainActor
final class ArticleViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: ArticleService

    init(service: ArticleService = ServiceFactory.makeArticleService()) {
        self.service = service
    }

    // Preview/test helper to construct a view model with predefined state.
    static func preview(articles: [Article] = [], isLoading: Bool = false, errorMessage: String? = nil, service: ArticleService = MockArticleService()) -> ArticleViewModel {
        let vm = ArticleViewModel(service: service)
        vm.articles = articles
        vm.isLoading = isLoading
        vm.errorMessage = errorMessage
        return vm
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
