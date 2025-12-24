import XCTest
@testable import EW_IOS

final class GhostArticleServiceTests: XCTestCase {

    func testDecodeNormalPost() throws {
        let data = normalPostJSON.data(using: .utf8)!
        let articles = try GhostArticleService.decodeArticlesForTest(from: data)
        XCTAssertEqual(articles.count, 1)
        let article = articles[0]
        XCTAssertEqual(article.id, "ghost-1")
        XCTAssertEqual(article.title, "Hello from Ghost")
        XCTAssertEqual(article.url, "https://etherworld.co/hello")
        XCTAssertEqual(article.tags, ["Protocol"])
        XCTAssertEqual(article.readingTimeMinutes, 5)
    }

    func testDecodeMissingOptionalFields() throws {
        let data = missingOptionalJSON.data(using: .utf8)!
        let articles = try GhostArticleService.decodeArticlesForTest(from: data)
        XCTAssertEqual(articles.count, 1)
        let article = articles[0]
        XCTAssertEqual(article.id, "ghost-2")
        XCTAssertEqual(article.title, "No Extras")
        XCTAssertEqual(article.excerpt, "")
        XCTAssertEqual(article.author, nil)
        XCTAssertTrue(article.tags.isEmpty)
        XCTAssertNil(article.readingTimeMinutes)
    }

    func testDecodeLongHTMLContent() throws {
        let data = longHtmlJSON.data(using: .utf8)!
        let articles = try GhostArticleService.decodeArticlesForTest(from: data)
        XCTAssertEqual(articles.count, 1)
        let article = articles[0]
        XCTAssertTrue(article.contentHTML.contains("<p>Paragraph 1</p>"))
        XCTAssertTrue(article.contentHTML.contains("<p>Paragraph 3</p>"))
    }
}

// MARK: - Fixtures
private let normalPostJSON = """
{
  "posts": [
    {
      "id": "ghost-1",
      "title": "Hello from Ghost",
      "excerpt": "Protocol update",
      "html": "<p>Content</p>",
      "published_at": "2025-12-01T10:00:00Z",
      "url": "https://etherworld.co/hello",
      "feature_image": "https://etherworld.co/img/hello.jpg",
      "primary_tag": { "name": "Protocol" },
      "reading_time": 5,
      "primary_author": { "name": "Author A" }
    }
  ]
}
"""

private let missingOptionalJSON = """
{
  "posts": [
    {
      "id": "ghost-2",
      "title": "No Extras",
      "excerpt": null,
      "html": null,
      "published_at": null,
      "url": null,
      "feature_image": null,
      "primary_tag": null,
      "reading_time": null,
      "primary_author": null
    }
  ]
}
"""

private let longHtmlJSON = """
{
  "posts": [
    {
      "id": "ghost-3",
      "title": "Long HTML",
      "excerpt": "Long body",
      "html": "<p>Paragraph 1</p><p>Paragraph 2</p><p>Paragraph 3</p>",
      "published_at": "2025-12-10T12:00:00Z",
      "url": "https://etherworld.co/long",
      "feature_image": null,
      "primary_tag": { "name": "Research" },
      "reading_time": 12,
      "primary_author": { "name": "Author B" }
    }
  ]
}
"""
