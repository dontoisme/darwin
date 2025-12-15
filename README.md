# Darwin

**Watch your iOS app evolve.** Git-aware visual regression testing and development timelapse for iOS.

Darwin helps you track UI changes across commits by intelligently capturing only the screens affected by your code changes, generating pixel-level diff reports, and building a visual history of your app's evolution.

## Features

- **Smart capture**: Only screenshot screens affected by changed source files
- **Pixel-level diff**: ImageMagick-powered comparison with HTML reports
- **Git-aware**: Organized by commit, tracks source file → screen mapping
- **Manifest-based**: Declarative mapping of screens to source files
- **CI-ready**: Works with any CI system, generates HTML reports

## Quick Start

```bash
# Install via Homebrew
brew tap dontoisme/darwin
brew install darwin

# Or clone and add to PATH
git clone https://github.com/dontoisme/darwin.git
export PATH="$PATH:$(pwd)/darwin/bin"

# Initialize in your iOS project
cd MyApp
darwin init

# Capture baseline screenshots
darwin capture --baseline

# Make changes, then capture again
darwin capture --smart

# Compare the changes
darwin diff baseline HEAD --html
open Screenshots/diff/report.html
```

## How It Works

1. **Manifest** (`Screenshots/manifest.json`) maps source files to screens
2. **Git diff** detects which Swift files changed since last capture
3. **Smart capture** runs only the XCUITests for affected screens
4. **ImageMagick** generates pixel-level diff images
5. **HTML report** shows before/after/diff side-by-side

## Commands

### `darwin init`

Initialize Darwin in your iOS project. Creates `darwin.json` config and `Screenshots/manifest.json`.

```bash
darwin init                              # Interactive setup
darwin init --project MyApp.xcodeproj    # Non-interactive
darwin init --with-templates             # Copy Swift helper files
```

### `darwin capture`

Capture screenshots from your app.

```bash
darwin capture                    # Smart capture (changed screens only)
darwin capture --baseline         # Capture ALL screens (first run)
darwin capture --all              # Force capture all screens
darwin capture --dry-run          # Show what would be captured
darwin capture --screens 01,02    # Capture specific screens
```

### `darwin diff`

Compare screenshots between commits.

```bash
darwin diff                           # Compare baseline vs latest
darwin diff abc1234 def5678           # Compare two commits
darwin diff baseline HEAD --html      # Generate HTML report
```

## Configuration

Darwin uses `darwin.json` in your project root:

```json
{
  "project": "MyApp.xcodeproj",
  "scheme": "MyApp",
  "testTarget": "MyAppUITests",
  "testClass": "ScreenshotTests",
  "destination": "platform=iOS Simulator,name=iPhone 16 Pro",
  "outputDir": "Screenshots",
  "manifest": "Screenshots/manifest.json"
}
```

## Manifest Format

The manifest maps screens to source files:

```json
{
  "version": "1.0",
  "screens": {
    "01-home": {
      "name": "Home",
      "description": "Main home screen",
      "test": "testScreenshot_01_Home",
      "sources": [
        "Sources/Views/HomeView.swift",
        "Sources/ViewModels/HomeViewModel.swift"
      ]
    }
  }
}
```

When any file in `sources` changes, that screen will be recaptured on the next `darwin capture --smart`.

## XCUITest Setup

Add the screenshot helper to your UI test target:

```swift
// In your test file
import XCTest

class ScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testScreenshot_01_Home() {
        // Navigate to home if needed
        takeScreenshot("01-home")
    }

    func testScreenshot_02_Settings() {
        app.buttons["Settings"].tap()
        takeScreenshot("02-settings")
    }
}
```

Copy `templates/XCUIApplication+Screenshots.swift` to your UI test target for the `takeScreenshot()` helper.

## Requirements

- macOS with Xcode 15+
- iOS Simulator
- `jq` (for JSON parsing): `brew install jq`
- ImageMagick (optional, for pixel diff): `brew install imagemagick`

## Use Cases

- **Visual regression testing**: Catch unintended UI changes before they ship
- **Design review**: Generate visual diffs for PR reviews
- **AI-assisted development**: Track changes made by AI coding assistants
- **Documentation**: Build a visual timeline of your app's evolution
- **Onboarding**: Show new team members how the UI evolved

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.
