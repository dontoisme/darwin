# Changelog

All notable changes to Darwin will be documented in this file.

## [1.5.0] - 2025-12-20

### Added
- **AI-Native Handoff** — `darwin init` outputs structured instructions for Claude Code/Cursor to complete setup
- **Auto-infer flows_to** — `darwin detect --add` now analyzes NavigationLink patterns to populate flows_to connections
- **AI prompt tip** — Shows "ask your AI assistant" tip for complex navigation patterns

### Improved
- **Scheme prompt** — Added hint to press enter to accept the default scheme
- **UI Test target guidance** — Explains what a UI Test target is with link to create one
- **Simulator selection** — Replaced text input with numbered list of available simulators
- **Clearer language** — Changed "Add to manifest?" to "Track these screens with Darwin?"

### Fixed
- Count calculation bug in darwin detect with newline characters

## [1.4.0] - 2025-12-20

### Added
- **"Wow" First-Time Experience** — `darwin init` now auto-detects screens, generates test stubs, and shows the demo viewer
- **Screen auto-detection during init** — Scans codebase for SwiftUI views and offers to add them to manifest
- **Test stub generation** — Creates ScreenshotTests.swift with test methods for all detected screens
- **Demo viewer prompt** — Opens the Darwin demo to show what the tool looks like
- **Focused "Next Steps"** — When tests are generated, shows exactly what navigation code to add

### Improved
- `darwin detect --list` — Output just view names for scripting
- `darwin detect --quiet` — Suppress banner for integration
- `darwin manifest sync --generate-file FILE` — Create complete ScreenshotTests.swift

## [1.3.0] - 2025-12-20

### Added
- **AI coding rules** — `darwin ai-rules` generates rules for Claude Code and Cursor to write Darwin-compatible code
- **FTUE AI rules prompt** — `darwin init` now asks if you want AI rules during setup
- **--with-ai-rules flag** — `darwin init --with-ai-rules` for non-interactive setup

### Files Generated
- `CLAUDE.md` — Rules for Claude Code (accessibility identifiers, NavigationLink patterns, XCUITest conventions)
- `.cursorrules` — Rules for Cursor (same patterns in Cursor format)

## [1.2.0] - 2025-12-19

### Added
- **Auto-detect views** — `darwin detect` finds new SwiftUI views not yet in manifest
- **Hook integration** — Post-commit hook now auto-detects and prompts to add new views
- **First-Time User Experience** — Interactive setup wizard with Autopilot, Guided, Manual, and Custom modes
- **Auto-open viewer** — Viewer opens automatically after capture (configurable)
- **Fuzz tolerance** — 5% default tolerance in diff to ignore time/battery changes

### Changed
- `darwin init` now prompts for automation mode preference
- `darwin.json` includes `mode` and `automation` settings
- Git hook auto-installed based on mode choice
- Mode-specific "Next Steps" messaging after init

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

[1.4.0]: https://github.com/dontoisme/darwin/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/dontoisme/darwin/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/dontoisme/darwin/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/dontoisme/darwin/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/dontoisme/darwin/releases/tag/v1.0.0
