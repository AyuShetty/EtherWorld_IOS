import Foundation

struct GhostArticleService: ArticleService {
    enum GhostServiceError: Error, LocalizedError {
        case missingAPIKey
        case invalidResponse
        case decodingFailed

        var errorDescription: String? {
            switch self {
            case .missingAPIKey: return "Ghost API key is missing."
            case .invalidResponse: return "Invalid response from Ghost API."
            case .decodingFailed: return "Failed to decode Ghost response."
            }
        }
    }

    struct Constants {
        // EtherWorld Ghost Content API
        static let baseURL = URL(string: "https://etherworld.co")!
        static let postsPath = "/ghost/api/content/posts/"
        // Content API key (read-only). Do not ship admin keys in client apps.
        static let apiKey = "5b9aefe2ea7623b8fd81c52dec"
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchArticles() async throws -> [Article] {
        guard Constants.apiKey != "<ghost-content-api-key>", !Constants.apiKey.isEmpty else {
            throw GhostServiceError.missingAPIKey
        }

        let request = makePostsRequest()
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw GhostServiceError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let ghost = try? decoder.decode(GhostPostsResponse.self, from: data) else {
            throw GhostServiceError.decodingFailed
        }

        return ghost.posts.map { $0.toArticle() }
    }

    /// Builds the GET request for Ghost posts with common query params.
    func makePostsRequest(limit: Int = 20) -> URLRequest {
        var components = URLComponents(url: Constants.baseURL, resolvingAgainstBaseURL: false) ?? URLComponents()
        components.path = Constants.postsPath
        components.queryItems = [
            URLQueryItem(name: "key", value: Constants.apiKey),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "fields", value: "id,title,excerpt,html,published_at,url,feature_image,primary_tag,reading_time,primary_author")
        ]

        let url = components.url ?? Constants.baseURL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}

#if DEBUG
// Test hook for decoding without hitting network.
extension GhostArticleService {
    static func decodeArticlesForTest(from data: Data) throws -> [Article] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let ghost = try decoder.decode(GhostPostsResponse.self, from: data)
        return ghost.posts.map { $0.toArticle() }
    }
}
#endif

// MARK: - DTOs
private struct GhostPostsResponse: Decodable {
    let posts: [GhostPost]
}

private struct GhostPost: Decodable {
    let id: String
    let title: String
    let excerpt: String?
    let html: String?
    let published_at: Date?
    let url: String?
    let feature_image: String?
    let primary_tag: GhostTag?
    let reading_time: Int?
    let primary_author: GhostAuthor?
}

private struct GhostTag: Decodable {
    let name: String
}

private struct GhostAuthor: Decodable {
    let name: String?
}

private extension GhostPost {
    func toArticle() -> Article {
        Article(
            id: id,
            title: title,
            excerpt: excerpt ?? "",
            contentHTML: html ?? "",
            publishedAt: published_at ?? Date(),
            url: url ?? "",
            author: primary_author?.name,
            imageURL: feature_image.flatMap { URL(string: $0) },
            tags: primary_tag?.name.map { [$0] } ?? [],
            readingTimeMinutes: reading_time
        )
    }
}
