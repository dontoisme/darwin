# Basic Darwin Example

This example shows the minimal setup for Darwin in an iOS project.

## Structure

```
basic/
├── darwin.json              # Darwin configuration
├── Screenshots/
│   └── manifest.json        # Screen-to-source mapping
└── README.md
```

## darwin.json

```json
{
  "project": "BasicApp.xcodeproj",
  "scheme": "BasicApp",
  "testTarget": "BasicAppUITests",
  "testClass": "ScreenshotTests",
  "destination": "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1",
  "outputDir": "Screenshots",
  "manifest": "Screenshots/manifest.json"
}
```

## Screenshots/manifest.json

```json
{
  "version": "1.0",
  "screens": {
    "01-home": {
      "name": "Home",
      "test": "testScreenshot_01_Home",
      "sources": ["BasicApp/ContentView.swift"]
    }
  }
}
```

## ScreenshotTests.swift

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
}
```

## Usage

```bash
# From your project directory
darwin capture --baseline    # Initial capture
darwin capture --smart       # After making changes
darwin diff --html           # View diff report
```
