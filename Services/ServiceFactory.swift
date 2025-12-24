import Foundation

/// Central place to choose which ArticleService to use at runtime.
/// Swap implementations here without touching UI layers.
enum ServiceFactory {
    private static let userDefaultsKey = "useGhostService"

    /// Returns the active ArticleService.
    /// Selection order: explicit flag (env/UserDefaults) → defaults (Mock in debug, Ghost in release).
    static func makeArticleService() -> ArticleService {
        let envFlag = ProcessInfo.processInfo.environment["USE_GHOST_SERVICE"]?.lowercased() == "true"
        let userDefaultsFlag = UserDefaults.standard.bool(forKey: userDefaultsKey)

        #if DEBUG
        if envFlag || userDefaultsFlag {
            return GhostArticleService()
        }
        return MockArticleService()
        #else
        if envFlag || userDefaultsFlag {
            return GhostArticleService()
        }
        return GhostArticleService()
        #endif
    }

    /// Persist toggle for runtime switching (debug use only).
    static func setUseGhostService(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: userDefaultsKey)
    }
}