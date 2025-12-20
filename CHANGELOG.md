# Changelog

All notable changes to Darwin will be documented in this file.

## [1.1.0] - 2024-12-19

### Added
- **Slack notifications** — Get notified when captures complete. Add `slack_webhook` to your `darwin.json` to enable.
- **Mobile-optimized viewer** — Demo viewer now works great on iPhone with proper touch handling, responsive screen sizes, and no pull-to-refresh conflicts.
- Back link from demo to landing page.

### Changed
- New tagline: "Your AI's eyes on the build"
- Repositioned for AI-assisted development and solo builders
- Landing page and README updated with new use cases
- Map connection lines now scale properly on mobile devices

### Fixed
- Touch panning on mobile no longer triggers Safari's pull-to-refresh
- Modal detail view scroll behavior on iOS
- Mini-map connection lines now connect to screens correctly

## [1.0.0] - 2024-12-15

### Added
- Initial release
- **Smart capture** — Only screenshot screens affected by changed source files
- **Visual timeline** — Interactive viewer with timeline playback and group filtering
- **App flow map** — Visualize screen connections and navigation paths
- **Pixel-level diff** — ImageMagick-powered comparison with HTML reports
- **Git hooks** — Auto-capture or prompt after commits with Swift changes
- **Git-aware** — Organized by commit, tracks source file → screen mapping
- Homebrew installation support

[1.1.0]: https://github.com/dontoisme/darwin/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/dontoisme/darwin/releases/tag/v1.0.0
