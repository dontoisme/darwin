# Darwin Roadmap

## Future Ideas

### Simulator Auto-Detection
- [ ] Auto-detect latest available simulator matching a pattern (e.g., "iPhone Pro")
- [ ] Resolve "latest" keyword to newest iOS version for a given device
- [ ] Fall back gracefully if preferred device unavailable
- [ ] `darwin init --simulator "iPhone Pro latest"` syntax
- [ ] Update darwin.json destination dynamically before capture

### Manifest Auto-Update
- [ ] `darwin manifest scan` - Detect new/changed source files and suggest updates
- [ ] Parse Swift files for `accessibilityIdentifier` assignments
- [ ] Scan XCUITest files for `func test*` methods
- [ ] Build-time hook to detect manifest drift
- [ ] `darwin manifest validate` - Check for missing sources or dead references

### GitHub Action
- [ ] Create `dontoisme/darwin-action` for CI integration
- [ ] macOS runner with iOS Simulator setup
- [ ] Baseline storage strategy (artifacts vs git branch vs S3)
- [ ] PR comment integration with visual diff summary
- [ ] Hosted viewer for PR review (GitHub Pages per-PR?)

### Cross-Platform?
Darwin is deeply integrated with the iOS ecosystem (XCUITest, Simulator, xcodebuild). Abstracting to other platforms would essentially be a different tool.

**Web/React already has solutions:**
- [Chromatic](https://www.chromatic.com/) - Storybook visual testing
- [Percy](https://percy.io/) - Visual review platform
- [Playwright](https://playwright.dev/) - Has built-in screenshot comparison
- [BackstopJS](https://github.com/garris/BackstopJS) - Visual regression testing

**What Darwin offers that's iOS-specific:**
- Smart capture based on Swift file changes
- XCUITest integration with accessibility identifiers
- iOS Simulator management
- Xcode build system integration

**If we wanted Darwin for web, it would need:**
- Puppeteer/Playwright instead of XCUITest
- File watcher or build hook instead of git diff on .swift
- Headless Chrome instead of iOS Simulator
- Different manifest format for components/routes

Probably better to use existing web tools and keep Darwin focused on iOS where there's less competition.
