import XCTest
@testable import EW_IOS

final class RSSArticleServiceTests: XCTestCase {

    func testParsesNormalItem() throws {
        let data = normalRSS.data(using: .utf8)!
        let articles = RSSArticleService.parseForTest(data: data)
        XCTAssertEqual(articles.count, 1)
        let article = try XCTUnwrap(articles.first)
        XCTAssertEqual(article.id, "https://etherworld.co/posts/1")
        XCTAssertEqual(article.title, "Normal Title")
        XCTAssertEqual(article.excerpt, "An excerpt")
        XCTAssertTrue(article.contentHTML.contains("<p>Full content</p>"))
        XCTAssertEqual(article.url, "https://etherworld.co/posts/1")
    }

    func testParsesMissingContentEncoded() throws {
        let data = missingContentEncoded.data(using: .utf8)!
        let articles = RSSArticleService.parseForTest(data: data)
        XCTAssertEqual(articles.count, 1)
        let article = try XCTUnwrap(articles.first)
        XCTAssertEqual(article.contentHTML, article.excerpt)
    }

    func testInvalidRSSReturnsEmpty() {
        let data = invalidRSS.data(using: .utf8)!
        let articles = RSSArticleService.parseForTest(data: data)
        XCTAssertTrue(articles.isEmpty)
    }
}

// MARK: - Fixtures
private let normalRSS = """
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <title>Etherworld</title>
    <item>
      <guid>https://etherworld.co/posts/1</guid>
      <link>https://etherworld.co/posts/1</link>
      <title>Normal Title</title>
      <description>An excerpt</description>
      <content:encoded><![CDATA[<p>Full content</p>]]></content:encoded>
      <pubDate>Mon, 23 Dec 2024 12:00:00 +0000</pubDate>
    </item>
  </channel>
</rss>
"""

private let missingContentEncoded = """
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <item>
      <guid>https://etherworld.co/posts/2</guid>
      <link>https://etherworld.co/posts/2</link>
      <title>No Content Encoded</title>
      <description>Desc only</description>
      <pubDate>Mon, 23 Dec 2024 12:00:00 +0000</pubDate>
    </item>
  </channel>
</rss>
"""

private let invalidRSS = """
<rss><channel><item><title>Broken
"""
