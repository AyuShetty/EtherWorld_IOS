import Foundation

@MainActor
final class TagFeedViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let tag: String
    private let service: ArticleService

    init(tag: String, service: ArticleService = ServiceFactory.makeArticleService()) {
        self.tag = tag
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await service.fetchArticles()
            articles = fetched
                .filter { $0.tags.map { $0.lowercased() }.contains(tag.lowercased()) }
                .sorted { $0.publishedAt > $1.publishedAt }
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load \(tag) articles."
            articles = []
        }
    }

    var title: String { "#\(tag)" }
}
