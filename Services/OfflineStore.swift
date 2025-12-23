import Foundation

/// Abstraction for offline storage of articles.
/// This is design-only; implement with FileManager/UserDefaults/CoreData later.
protocol OfflineStore {
    func save(article: Article) async throws
    func fetchSavedArticles() async throws -> [Article]
    func delete(articleID: String) async throws
    func isSaved(articleID: String) async -> Bool
}

// Placeholder implementation to be replaced with a real store.
struct NoopOfflineStore: OfflineStore {
    func save(article: Article) async throws {}
    func fetchSavedArticles() async throws -> [Article] { [] }
    func delete(articleID: String) async throws {}
    func isSaved(articleID: String) async -> Bool { false }
}