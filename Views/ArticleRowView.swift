import SwiftUI

struct ArticleRowView: View {
    let article: Article

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: article.publishedAt)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(article.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .accessibilityIdentifier("article_title_\(article.id)")

                    if let series = article.seriesBadge {
                        Text(series)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }

                Text(article.excerpt.isEmpty ? "No summary available." : article.excerpt)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .accessibilityIdentifier("article_excerpt_\(article.id)")

                HStack(spacing: 8) {
                    Label(formattedDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("article_date_\(article.id)")

                    if let minutes = article.readingTimeMinutes {
                        Label("\(minutes) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let firstTag = article.tags.first {
                        Text(firstTag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.96))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Article: \(article.title). Published \(formattedDate)")
    }

    private var thumbnail: some View {
        ZStack {
            if let url = article.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        placeholder
                    case .empty:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 96, height: 96)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemGray5), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "photo")
                .foregroundColor(.secondary)
        }
    }

}

extension Article {
    var seriesBadge: String? {
        let titleLower = title.lowercased()
        if titleLower.contains("weekly") { return "Weekly" }
        if titleLower.contains("bulletin") { return "Bulletin" }

        let tagSet = Set(tags.map { $0.lowercased() })
        if tagSet.contains("weekly") { return "Weekly" }
        if tagSet.contains("bulletin") { return "Bulletin" }
        return nil
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
