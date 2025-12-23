import SwiftUI

struct ArticleDetailView: View {
    @ObservedObject var viewModel: ArticleDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.article.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("detail_title")

                Text(viewModel.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("detail_date")

                Divider()

                Text(viewModel.attributedContent)
                    .font(.body)
                    .accessibilityIdentifier("detail_content")
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Article detail for \(viewModel.article.title)")
    }
}

// MARK: - Previews
#Preview {
    let sample = Article.previewSamples().first ?? Article(
        id: "placeholder",
        title: "Sample Title",
        excerpt: "",
        contentHTML: "<p>Sample body</p>",
        publishedAt: Date(),
        url: ""
    )
    NavigationStack {
        ArticleDetailView(viewModel: ArticleDetailViewModel(article: sample))
    }
}

#Preview("Missing Content") {
    let empty = Article(
        id: "empty",
        title: "Draft without body",
        excerpt: "",
        contentHTML: "",
        publishedAt: Date(),
        url: "",
        author: nil,
        imageURL: nil,
        tags: [],
        readingTimeMinutes: nil
    )
    NavigationStack {
        ArticleDetailView(viewModel: ArticleDetailViewModel(article: empty))
    }
}

#Preview("Long Content") {
    let longBody = String(repeating: "<p>Long paragraph content.</p>", count: 20)
    let long = Article(
        id: "long",
        title: "In-depth: Beacon chain economics",
        excerpt: "A deep look at incentives.",
        contentHTML: longBody,
        publishedAt: Date(),
        url: "https://example.com/long",
        author: "Researcher",
        imageURL: nil,
        tags: ["Research"],
        readingTimeMinutes: 18
    )
    NavigationStack {
        ArticleDetailView(viewModel: ArticleDetailViewModel(article: long))
    }
}
