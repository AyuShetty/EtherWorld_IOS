import SwiftUI

struct ArticleDetailView: View {
    @ObservedObject var viewModel: ArticleDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.article.title)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(viewModel.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()

                Text(viewModel.attributedContent)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
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
