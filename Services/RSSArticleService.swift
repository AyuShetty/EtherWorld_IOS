import Foundation

/// RSS-based ArticleService fallback for Ghost.
struct RSSArticleService: ArticleService {
    private let feedURL: URL
    private let session: URLSession

    init(feedURL: URL = URL(string: "https://etherworld.co/rss/")!, session: URLSession = .shared) {
        self.feedURL = feedURL
        self.session = session
    }

    func fetchArticles() async throws -> [Article] {
        let (data, _) = try await session.data(from: feedURL)
        // Parse defensively; return empty on malformed XML.
        return RSSParser.parse(data: data)
    }
}

// MARK: - Parser
private enum RSSParser {
    static func parse(data: Data) -> [Article] {
        let delegate = RSSParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldResolveExternalEntities = false
        parser.shouldProcessNamespaces = true
        parser.parse()
        // If parsing failed, return empty; never crash caller.
        if parser.parserError != nil {
            return []
        }
        return delegate.articles
    }
}

private final class RSSParserDelegate: NSObject, XMLParserDelegate {
    private(set) var articles: [Article] = []

    private var currentItem: RSSItem?
    private var currentElement: String = ""
    private var accumulator: String = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName.lowercased()
        accumulator = ""
        if currentElement == "item" {
            currentItem = RSSItem()
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        accumulator.append(string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard var item = currentItem else { return }
        let value = accumulator.trimmingCharacters(in: .whitespacesAndNewlines)
        switch elementName.lowercased() {
        case "guid":
            item.guid = value
        case "link":
            item.link = value
        case "title":
            item.title = value
        case "description":
            item.description = value
        case "content:encoded":
            item.contentEncoded = value
        case "pubdate":
            item.pubDateString = value
        case "item":
            if let article = item.toArticle() {
                articles.append(article)
            }
            currentItem = nil
        default:
            break
        }
        accumulator = ""
    }
}

private struct RSSItem {
    var guid: String?
    var link: String?
    var title: String?
    var description: String?
    var contentEncoded: String?
    var pubDateString: String?

    func toArticle() -> Article? {
        guard let title = title, !title.isEmpty else { return nil }
        let id = guid?.isEmpty == false ? guid! : (link ?? UUID().uuidString)
        let url = link ?? ""
        let excerpt = description ?? ""
        let content = contentEncoded ?? ""
        let published = Self.rfc822Date(from: pubDateString) ?? Date()

        return Article(
            id: id,
            title: title,
            excerpt: excerpt,
            contentHTML: content.isEmpty ? excerpt : content,
            publishedAt: published,
            url: url,
            author: nil,
            imageURL: nil,
            tags: [],
            readingTimeMinutes: nil
        )
    }

    private static func rfc822Date(from string: String?) -> Date? {
        guard let string = string, !string.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: string)
    }
}

#if DEBUG
// Test hook
extension RSSArticleService {
    static func parseForTest(data: Data) -> [Article] {
        RSSParser.parse(data: data)
    }
}
#endif
