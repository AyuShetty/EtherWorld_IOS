import Foundation

/// Central place to choose which ArticleService to use at runtime.
/// Swap implementations here without touching UI layers.
enum ServiceFactory {
    /// Returns the active ArticleService.
    /// Use compile-time flags or environment variables as needed.
    static func makeArticleService() -> ArticleService {
        #if DEBUG
        // Default to mock in debug for stability.
        return MockArticleService()
        #else
        // Point to Ghost when real networking is enabled.
        return GhostArticleService()
        #endif
    }
}