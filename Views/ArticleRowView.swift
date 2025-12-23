import SwiftUI

struct ArticleRowView: View {
    let article: Article

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: article.publishedAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.title)
                .font(.headline)
                .foregroundColor(.primary)
                .accessibilityIdentifier("article_title_\(article.id)")

            Text(article.excerpt)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .accessibilityIdentifier("article_excerpt_\(article.id)")

            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityIdentifier("article_date_\(article.id)")
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Article: \(article.title). Published \(formattedDate)")
    }
}

// MARK: - Previews
#Preview {
    List(Article.previewSamples()) { article in
        ArticleRowView(article: article)
    }
}

#Preview("Edge Cases") {
    List {
        ArticleRowView(article: Article(
            id: "edge-1",
            title: String(repeating: "Long title ", count: 5),
            excerpt: String(repeating: "Long excerpt text that should truncate. ", count: 4),
            contentHTML: "",
            publishedAt: Date(),
            url: "",
            author: "Author",
            imageURL: nil,
            tags: ["Tag"],
            readingTimeMinutes: 12
        ))
        ArticleRowView(article: Article(
            id: "edge-2",
            title: "No excerpt",
            excerpt: "",
            contentHTML: "",
            publishedAt: Date(),
            url: "",
            author: nil,
            imageURL: nil,
            tags: [],
            readingTimeMinutes: nil
        ))
    }
}
