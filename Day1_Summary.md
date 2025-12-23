# Day 1 Summary — Etherworld iOS (SwiftUI + MVVM)

## What we finalized

- Data model (`Models/Article.swift`):
  - Required fields: `id`, `title`, `excerpt`, `contentHTML`, `publishedAt`, `url`.
  - Optional metadata: `author`, `imageURL`, `tags`, `readingTimeMinutes`.
  - The model is used across services, view models, and views.

- Mock data (`Services/MockArticleService.swift`):
  - Realistic CMS-like samples including images, authors, tags, long content, edge cases (future-dated article, empty excerpt/content).
  - Mock data exercises UI behaviors: truncation, long reads, missing metadata.

- Data flow (Service → ViewModel → View):
  - `ArticleService` protocol defines fetching contract.
  - `MockArticleService` provides deterministic data for development.
  - `ArticleViewModel` performs fetching, sorting by `publishedAt`, and exposes `@Published` state to views.
  - Views (`HomeFeedView`, `ArticleRowView`, `ArticleDetailView`) observe view models and display the data. Navigation uses `NavigationStack` + `navigationDestination`.

- Tests & Previews:
  - Unit tests for `ArticleViewModel` cover loading state, sorting, and failure scenarios (`Tests/ArticleViewModelTests.swift`).
  - Unit tests for `ArticleDetailViewModel` added for date formatting and attributed content behavior (`Tests/ArticleDetailViewModelTests.swift`).
  - SwiftUI previews added for key views and use dependency injection for stability.

- Ghost service scaffold (`Services/GhostArticleService.swift`):
  - Contains endpoint constants and a `makePostsRequest` builder.
  - `fetchArticles()` is intentionally left as a TODO; stubbed to throw `notImplemented`.

## Remaining (Day 1 scope)

- Implement real `GhostArticleService.fetchArticles()` (networking, decoding, mapping to `Article`) — *outside Day 1 scope unless you want it now*.

## How to switch Mock vs Ghost

- Use dependency injection. Create your desired service and pass it to `ArticleViewModel(service:)`. Optionally, add a small `ServiceFactory` or `AppConfig` for a runtime toggle.

## User flow

1. Open app → Home feed auto-fetches articles.
2. Browse list → tap article row.
3. Article detail shows title, date, content, and metadata.
4. (Future) Open link/share external URL.

---

If you want, I can now implement a small `ServiceFactory` or `AppConfig` that wires `MockArticleService` in debug and `GhostArticleService` (once implemented) in release, or implement the Ghost decoder next — let me know which one to take on after Day 1 tasks.
