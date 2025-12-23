import Foundation

struct MockArticleService: ArticleService {
    func fetchArticles() async throws -> [Article] {
        MockArticleService.sampleArticles
    }

    // Static mock resembling a CMS payload
    static let sampleArticles: [Article] = {
        let formatter = ISO8601DateFormatter()
        return [
            Article(
                id: "ew-001",
                title: "EIP-4844 Ships on Mainnet",
                excerpt: "Proto-danksharding lands with lower blob fees and improved data availability.",
                contentHTML: """
                <h2>Why it matters</h2>
                <p>Proto-danksharding introduces blob-carrying transactions to reduce L2 costs.</p>
                <img src=\"https://etherworld.example/assets/eip-4844.png\" alt=\"EIP-4844\" />
                <p>Rollups benefit from cheaper data and improved throughput.</p>
                """,
                publishedAt: formatter.date(from: "2025-12-10T15:04:05Z") ?? Date(),
                url: "https://etherworld.example/eip-4844",
                author: "Ada Validator",
                imageURL: URL(string: "https://etherworld.example/assets/eip-4844.png"),
                tags: ["EIP", "Sharding", "Rollups"],
                readingTimeMinutes: 6
            ),
            Article(
                id: "ew-002",
                title: "The Merge, Two Years Later",
                excerpt: "Energy savings, validator participation, and MEV dynamics in review.",
                contentHTML: """
                <p>Post-Merge, Ethereum reduced energy usage by ~99.95%.</p>
                <p>Validator set grew steadily, while MEV-boost adoption reshaped proposer rewards.</p>
                <p><strong>Key takeaways:</strong></p>
                <ol>
                  <li>Energy reduction</li>
                  <li>Validator economics changed</li>
                  <li>MEV markets evolved</li>
                </ol>
                """,
                publishedAt: formatter.date(from: "2025-11-28T09:30:00Z") ?? Date(),
                url: "https://etherworld.example/merge-two-years",
                author: "Satoshi Burner",
                imageURL: URL(string: "https://etherworld.example/assets/merge.jpg"),
                tags: ["Merge", "Proof-of-Stake"],
                readingTimeMinutes: 8
            ),
            Article(
                id: "ew-003",
                title: "Road to Verkle Trees",
                excerpt: "State expiry, smaller witnesses, and the path to stateless clients.",
                contentHTML: """
                <p>Verkle trees promise succinct proofs, enabling lighter clients and faster sync.</p>
                <blockquote>Benchmarks show smaller proofs and faster verification times.</blockquote>
                """,
                publishedAt: formatter.date(from: "2025-11-05T12:00:00Z") ?? Date(),
                url: "https://etherworld.example/verkle-roadmap",
                author: "Chain Researcher",
                tags: ["Verkle", "Client"],
                readingTimeMinutes: 4
            ),
            // Edge cases to exercise UI
            Article(
                id: "ew-004",
                title: "A very long-form deep dive into bytecode and optimizations for EVM clients",
                excerpt: "This is a long excerpt that should be truncated in the list. It contains detailed analysis and benchmarking results.",
                contentHTML: String(repeating: "<p>Long form content paragraph.</p>", count: 30),
                publishedAt: formatter.date(from: "2026-01-01T00:00:00Z") ?? Date(), // future-dated
                url: "https://etherworld.example/deep-dive-bytecode",
                author: "Dev Rel",
                tags: ["Deep Dive", "EVM"],
                readingTimeMinutes: 25
            ),
            Article(
                id: "ew-005",
                title: "Draft: State Expiry Proposal",
                excerpt: "",
                contentHTML: "",
                publishedAt: formatter.date(from: "2024-12-01T08:00:00Z") ?? Date(),
                url: "https://etherworld.example/state-expiry-draft",
                author: nil,
                tags: [],
                readingTimeMinutes: nil
            )
        ]
    }()
}
