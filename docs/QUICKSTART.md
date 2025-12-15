# Darwin Quick Start Guide

Get Darwin running in your iOS project in 5 minutes.

## 1. Install Darwin

**Option A: Homebrew (recommended)**
```bash
brew tap dontoisme/darwin
brew install darwin
```

**Option B: Clone and add to PATH**
```bash
git clone https://github.com/dontoisme/darwin.git ~/darwin
echo 'export PATH="$PATH:$HOME/darwin/bin"' >> ~/.zshrc
source ~/.zshrc
```

## 2. Initialize Your Project

```bash
cd /path/to/YourApp
darwin init
```

This creates:
- `darwin.json` - Configuration file
- `Screenshots/manifest.json` - Screen-to-source mapping

## 3. Add Screenshot Helper to Your Tests

Copy the helper file to your UI test target:

```bash
cp ~/darwin/templates/XCUIApplication+Screenshots.swift YourAppUITests/Helpers/
```

Then add it to your Xcode project (drag into YourAppUITests target).

## 4. Create Your First Screenshot Test

Create `YourAppUITests/ScreenshotTests.swift`:

```swift
import XCTest

class ScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func testScreenshot_01_Home() {
        // App launches to home by default
        takeScreenshot("01-home")
    }

    func testScreenshot_02_Settings() {
        // Navigate to settings
        app.buttons["settingsButton"].tap()
        takeScreenshot("02-settings")
    }
}
```

## 5. Update the Manifest

Edit `Screenshots/manifest.json`:

```json
{
  "version": "1.0",
  "screens": {
    "01-home": {
      "name": "Home",
      "test": "testScreenshot_01_Home",
      "sources": ["YourApp/Views/HomeView.swift"]
    },
    "02-settings": {
      "name": "Settings",
      "test": "testScreenshot_02_Settings",
      "sources": ["YourApp/Views/SettingsView.swift"]
    }
  }
}
```

## 6. Capture Baseline Screenshots

```bash
darwin capture --baseline
```

This runs all screenshot tests and saves them to `Screenshots/baseline/`.

## 7. Make Changes and Capture Again

After making UI changes:

```bash
# Commit your changes first
git add . && git commit -m "Update home screen"

# Smart capture only re-captures affected screens
darwin capture --smart
```

## 8. View the Diff

```bash
darwin diff baseline HEAD --html
open Screenshots/diff/report.html
```

## Tips

### Add Accessibility Identifiers

For reliable navigation, add identifiers to your views:

```swift
// SwiftUI
Button("Settings") { }
    .accessibilityIdentifier("settingsButton")

// UIKit
button.accessibilityIdentifier = "settingsButton"
```

### Git Ignore Test Results

Add to `.gitignore`:
```
TestResults/
Screenshots/diff/
```

### Dry Run First

See what would be captured without running tests:
```bash
darwin capture --smart --dry-run
```

## Next Steps

- Read [MANIFEST-SCHEMA.md](MANIFEST-SCHEMA.md) for manifest options
- Check [XCUITEST-SETUP.md](XCUITEST-SETUP.md) for advanced test patterns
- See [VISION.md](VISION.md) for the roadmap
