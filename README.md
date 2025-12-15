# Darwin

**Watch your iOS app evolve.** Git-aware visual regression testing and development timelapse for iOS.

Darwin tracks UI changes across commits by intelligently capturing only screens affected by your code changes, generating pixel-level diff reports, and building a visual timeline of your app's evolution.

## Features

- **Smart capture** — Only screenshot screens affected by changed source files
- **Visual timeline** — Interactive viewer with timeline playback, app flow map, and group filtering
- **Pixel-level diff** — ImageMagick-powered comparison with HTML reports
- **Git-aware** — Organized by commit, tracks source file → screen mapping
- **Git hooks** — Auto-capture or prompt after commits with Swift changes
- **CI-ready** — Works with any CI system, generates HTML reports

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
darwin capture

# Open the visual timeline
darwin viewer
```

## Commands

| Command | Description |
|---------|-------------|
| `darwin init` | Initialize Darwin in your project |
| `darwin capture` | Smart capture (only changed screens) |
| `darwin capture --baseline` | Capture all screens (first run) |
| `darwin diff` | Compare screenshots between captures |
| `darwin viewer` | Open interactive timeline viewer (auto-regenerates after capture) |
| `darwin manifest sync` | Sync manifest with viewer (auto-runs after capture) |
| `darwin status` | Show current state and pending changes |
| `darwin hook install` | Install git hook for auto-capture |

### darwin viewer

The unified viewer provides three modes:
- **Single** — Browse any capture
- **Compare** — Side-by-side diff between captures
- **Map** — Visual app flow with timeline playback, group filtering, and mouse-centered zoom

### darwin hook

Integrate Darwin into your git workflow:

```bash
darwin hook install          # Prompt after commits with Swift changes
darwin hook install --auto   # Auto-capture after commits
darwin hook status           # Check if hook is installed
```

## How It Works

1. **Manifest** (`Screenshots/manifest.json`) maps source files to screens
2. **Git diff** detects which Swift files changed since last capture
3. **Smart capture** runs only the XCUITests for affected screens
4. **Timeline** tracks all captures with commit info
5. **Auto-sync** regenerates viewer with updated manifest after each capture
6. **Viewer** lets you explore your app's visual evolution

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

The manifest maps screens to source files and defines app flow:

```json
{
  "version": "1.0",
  "screens": {
    "01-home": {
      "name": "Home",
      "test": "testScreenshot_01_Home",
      "sources": ["Sources/Views/HomeView.swift"],
      "flows_to": ["02-settings", "03-profile"]
    }
  },
  "groups": {
    "main": {
      "name": "Main",
      "color": "#58a6ff",
      "screens": ["01-home", "02-settings"]
    }
  }
}
```

## XCUITest Setup

Add screenshot tests to your UI test target:

```swift
import XCTest

class ScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testScreenshot_01_Home() {
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

- **Visual regression testing** — Catch unintended UI changes before they ship
- **Design review** — Generate visual diffs for PR reviews
- **AI-assisted development** — Track changes made by AI coding assistants
- **Documentation** — Build a visual timeline of your app's evolution
- **Onboarding** — Show new team members how the UI evolved

## License

MIT License - see [LICENSE](LICENSE)
