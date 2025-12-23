import Foundation

/// Article model used throughout the app.
///
/// Core fields are required to represent content in lists and detail screens.
/// Additional fields are optional and may be provided by the CMS.
struct Article: Identifiable, Hashable {
    let id: String
    let title: String
    let excerpt: String
    let contentHTML: String
    let publishedAt: Date
    let url: String

    // Optional metadata commonly provided by CMS
    let author: String?
    let imageURL: URL?
    let tags: [String]
    let readingTimeMinutes: Int?

    init(
        id: String,
        title: String,
        excerpt: String,
        contentHTML: String,
        publishedAt: Date,
        url: String,
        author: String? = nil,
        imageURL: URL? = nil,
        tags: [String] = [],
        readingTimeMinutes: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.excerpt = excerpt
        self.contentHTML = contentHTML
        self.publishedAt = publishedAt
        self.url = url
        self.author = author
        self.imageURL = imageURL
        self.tags = tags
        self.readingTimeMinutes = readingTimeMinutes
    }
}

extension Article {
    static func previewSamples() -> [Article] {
        MockArticleService.sampleArticles
    }
}
