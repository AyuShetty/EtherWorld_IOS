import XCTest
@testable import EW_IOS

final class ArticleViewModelTests: XCTestCase {

    @MainActor
    func testLoadingStateUpdates() async {
        let service = SlowArticleService(articles: Article.previewSamples(), delay: 0.05)
        let viewModel = ArticleViewModel(service: service)

        let task = Task { await viewModel.loadArticles() }
        // Allow task to start
        try? await Task.sleep(nanoseconds: 10_000_000)
        XCTAssertTrue(viewModel.isLoading, "isLoading should be true while fetching")

        await task.value
        XCTAssertFalse(viewModel.isLoading, "isLoading should return to false after fetch")
    }

    @MainActor
    func testArticlesSortedByPublishedDateDescending() async throws {
        let older = Article(
            id: "old",
            title: "Old",
            excerpt: "",
            contentHTML: "",
            publishedAt: Date(timeIntervalSince1970: 0),
            url: ""
        )
        let newer = Article(
            id: "new",
            title: "New",
            excerpt: "",
            contentHTML: "",
            publishedAt: Date(timeIntervalSince1970: 1),
            url: ""
        )
        let service = SlowArticleService(articles: [older, newer], delay: 0)
        let viewModel = ArticleViewModel(service: service)

        await viewModel.loadArticles()
        XCTAssertEqual(viewModel.articles.first?.id, "new")
    }

    @MainActor
    func testErrorHandlingSetsMessage() async {
        let service = FailingArticleService()
        let viewModel = ArticleViewModel(service: service)

        await viewModel.loadArticles()
        XCTAssertEqual(viewModel.errorMessage, "Failed to load articles.")
        XCTAssertTrue(viewModel.articles.isEmpty)
    }
}

// MARK: - Test Doubles
private struct SlowArticleService: ArticleService {
    let articles: [Article]
    let delay: TimeInterval

    func fetchArticles() async throws -> [Article] {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        return articles
    }
}

private struct FailingArticleService: ArticleService {
    enum TestError: Error { case failed }
    func fetchArticles() async throws -> [Article] {
        throw TestError.failed
    }
}
