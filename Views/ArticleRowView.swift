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

            Text(article.excerpt)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Previews
#Preview {
    List(Article.previewSamples()) { article in
        ArticleRowView(article: article)
    }
}
