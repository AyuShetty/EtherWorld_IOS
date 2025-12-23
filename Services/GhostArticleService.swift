import Foundation

struct GhostArticleService: ArticleService {
    enum GhostServiceError: Error {
        case notImplemented
    }

    struct Constants {
        // TODO: Replace with your Ghost content endpoint and key
        static let baseURL = URL(string: "https://ghost.example")!
        static let postsPath = "/ghost/api/content/posts/"
        static let apiKey = "<ghost-content-api-key>"
    }

    func fetchArticles() async throws -> [Article] {
        // TODO: Implement real network fetching. Keep this stub for now.
        throw GhostServiceError.notImplemented
    }

    /// Builds the GET request for Ghost posts with common query params.
    func makePostsRequest(limit: Int = 20) -> URLRequest {
        var components = URLComponents(url: Constants.baseURL, resolvingAgainstBaseURL: false) ?? URLComponents()
        components.path = Constants.postsPath
        components.queryItems = [
            URLQueryItem(name: "key", value: Constants.apiKey),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "fields", value: "id,title,excerpt,html,published_at,url")
        ]

        let url = components.url ?? Constants.baseURL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
