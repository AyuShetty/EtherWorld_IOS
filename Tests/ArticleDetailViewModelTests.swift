import XCTest
@testable import EW_IOS

final class ArticleDetailViewModelTests: XCTestCase {

    @MainActor
    func testFormattedDateMatchesFormatter() {
        let date = Date(timeIntervalSince1970: 1_600_000_000) // deterministic timestamp
        let article = Article(id: "a1", title: "T", excerpt: "", contentHTML: "<p>Hi</p>", publishedAt: date, url: "", author: "A", tags: [], readingTimeMinutes: 2)
        let vm = ArticleDetailViewModel(article: article)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        // Use current locale to mirror implementation
        formatter.locale = Locale.current

        let expected = formatter.string(from: date)
        XCTAssertEqual(vm.formattedDate, expected)
    }

    @MainActor
    func testAttributedContentWithHTMLContainsText() {
        let article = Article(id: "a2", title: "T", excerpt: "", contentHTML: "<p>Hello <strong>World</strong></p>", publishedAt: Date(), url: "", author: nil, tags: [], readingTimeMinutes: nil)
        let vm = ArticleDetailViewModel(article: article)

        let content = vm.attributedContent
        XCTAssertTrue(content.description.contains("Hello"))
        XCTAssertTrue(content.description.contains("World"))
    }

    @MainActor
    func testAttributedContentPlainTextEquals() {
        let body = "Plain content without HTML"
        let article = Article(id: "a3", title: "T", excerpt: "", contentHTML: body, publishedAt: Date(), url: "", author: nil, tags: [], readingTimeMinutes: nil)
        let vm = ArticleDetailViewModel(article: article)

        XCTAssertEqual(vm.attributedContent, AttributedString(body))
    }
}
