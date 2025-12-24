import Foundation

/// Central place to choose which ArticleService to use at runtime.
/// Swap implementations here without touching UI layers.
enum ServiceFactory {
    private static let userDefaultsKey = "useGhostService"

    /// Returns the active ArticleService.
    /// Selection order: explicit flag (env/UserDefaults) → defaults (Mock in debug, Ghost+RSS fallback in release).
    static func makeArticleService() -> ArticleService {
        let envFlag = ProcessInfo.processInfo.environment["USE_GHOST_SERVICE"]?.lowercased() == "true"
        let userDefaultsFlag = UserDefaults.standard.bool(forKey: userDefaultsKey)

        #if DEBUG
        if envFlag || userDefaultsFlag {
            return ghostWithFallback()
        }
        return MockArticleService()
        #else
        if envFlag || userDefaultsFlag {
            return ghostWithFallback()
        }
        return ghostWithFallback()
        #endif
    }

    /// Persist toggle for runtime switching (debug use only).
    static func setUseGhostService(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: userDefaultsKey)
    }

    private static func ghostWithFallback() -> ArticleService {
        GhostThenRSSService(primary: GhostArticleService(), fallback: RSSArticleService())
    }
}

// MARK: - Fallback wrapper
private struct GhostThenRSSService: ArticleService {
    let primary: ArticleService
    let fallback: ArticleService

    func fetchArticles() async throws -> [Article] {
        do {
            let ghostArticles = try await primary.fetchArticles()
            return ghostArticles
        } catch {
            let rssResult = try await fallback.fetchArticles()
            if rssResult.isEmpty {
                throw error
            }
            return rssResult
        }
    }
}