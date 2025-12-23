# Offline Reading Plan (Design Only)

## Goals
- Allow users to save articles for offline reading.
- Preserve readability (HTML/attributed text) when offline.
- Avoid blocking the online experience; offline is additive.

## Scope (not implemented yet)
- No persistence code in this iteration; this is a contract and flow.
- Target: lightweight file/JSON cache plus saved HTML content.

## Data to store per article
- `id` (String)
- `title` (String)
- `excerpt` (String)
- `contentHTML` (String) — raw HTML to render later
- `publishedAt` (Date)
- `url` (String)
- Optional metadata: `author`, `imageURL`, `tags`, `readingTimeMinutes`

## Proposed storage shape (JSON + blobs)
- JSON file for article metadata + HTML string. Example key: `offline_articles.json`.
- Optional image caching: store downloaded images under `Images/<article-id>/hero.jpg` when added later.

## API surface (to add later)
- `OfflineStore` protocol with:
  - `func save(article: Article) async throws`
  - `func fetchSavedArticles() async throws -> [Article]`
  - `func delete(articleID: String) async throws`
  - `func isSaved(articleID: String) async -> Bool`
- Implementation idea: `FileOfflineStore` using `FileManager` + `JSONEncoder/Decoder`.

## App flow (online/offline)
- Online: Service → `ArticleViewModel` → Views (as today).
- Offline list: `OfflineViewModel` queries `OfflineStore` and renders a list of saved articles.
- Detail (offline): if offline and article is saved, render from offline store; otherwise show “Download to read offline” CTA.

## UX notes
- Show a badge or icon on rows that are saved for offline.
- Add a “Save for offline” button in detail view (toggles saved state).
- Provide clear status messages: "Saved for offline", "Removed from offline", "Not available offline".
- Handle offline attempts gracefully: if user tries to save while offline but content not cached, show a non-blocking error.

## Error handling (future)
- Storage errors: surface user-friendly toasts/banners; log details.
- Versioning: include a schema version in cached JSON; migrate by re-fetching if incompatible.

## Testing ideas
- Unit tests: save/fetch/delete/idempotency; corruption recovery (bad JSON should not crash).
- Integration: simulate offline mode, ensure offline detail renders without network.
- UI tests: verify badges and CTA states.

## Future considerations
- Expiry policy for cached content (e.g., 30 days) with background cleanup.
- Storage size limits and eviction policy.
- Encryption at rest if storing sensitive drafts (likely not needed for public articles).
