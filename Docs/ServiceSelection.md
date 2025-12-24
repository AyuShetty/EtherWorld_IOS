# Service Selection

Audience: future contributors; non-technical summary.

- **Default (Debug builds):** Uses mock data via `MockArticleService` for stability and offline development.
- **Default (Release/when explicitly enabled):** Uses `GhostArticleService` as the primary source.
- **Automatic fallback:** If Ghost fails (network/decoding), `RSSArticleService` is used to populate the feed. RSS never overrides a successful Ghost response.
- **Force Ghost in Debug:** Set the env var `USE_GHOST_SERVICE=true` or set the UserDefaults flag `useGhostService` (e.g., via launch arguments) to use Ghost (+ RSS fallback) instead of Mock.
- **Mock data:** Intended only for development/testing; not used in release unless you explicitly disable Ghost.
