import Foundation
import SwiftUI

@MainActor
final class ArticleDetailViewModel: ObservableObject {
    let article: Article

    init(article: Article) {
        self.article = article
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: article.publishedAt)
    }

    // Renders HTML into attributed text; falls back to plain text if conversion fails.
    var attributedContent: AttributedString {
        guard let data = article.contentHTML.data(using: .utf8),
              let attributed = try? AttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
              ) else {
            return AttributedString(article.contentHTML)
        }
        return attributed
    }
}
