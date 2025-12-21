# Darwin Visual Documentation Patterns

This iOS project uses Darwin for visual regression tracking.

## Setting Up Darwin

When asked to set up Darwin, run:
```bash
darwin init --ai-interactive
```

Parse the JSON output and ask the user to select:
- Scheme (from Xcode project)
- Simulator device
- Automation mode

Then run with selections:
```bash
darwin init --ai --scheme <scheme> --destination 'platform=iOS Simulator,name=<device>' --mode <mode>
```

Follow the "AI ASSISTANT" handoff to complete setup.

## Rules for SwiftUI Code

1. ALWAYS add .accessibilityIdentifier() to interactive elements (buttons, links, toggles, text fields)
2. Use snake_case naming: screen_element_action (e.g., home_button_settings)
3. Prefer NavigationLink with typed values: NavigationLink("Label", value: Screen.case)
4. If ScreenIdentifiers enum exists, use it for identifier constants

### Examples

```swift
// Good - has accessibility identifier
Button("Settings") { ... }
    .accessibilityIdentifier("home_button_settings")

// Good - typed NavigationLink with identifier
NavigationLink("Theme", value: SettingsScreen.theme)
    .accessibilityIdentifier("settings_row_theme")
```

## Rules for XCUITests

1. Use takeScreenshotWithElements("XX-name", app: app) for Darwin captures
2. Prefix screenshot names with two-digit ordering (01-home, 02-settings)
3. Navigate using accessibility identifiers

```swift
func testScreenshot_01_Home() {
    let app = XCUIApplication()
    app.launch()
    takeScreenshotWithElements("01-home", app: app)
}
```

## When Adding Screens

Update Screenshots/manifest.json with:
1. Screen definition in `screens` with sources array and flows_to connections
2. Add screen ID to appropriate group in `groups`
3. Create new group if it's a new app area

```json
{
  "screens": {
    "01-home": {
      "name": "Home",
      "test": "testScreenshot_01_Home",
      "sources": ["Sources/Views/HomeView.swift"],
      "flows_to": [{"target": "02-settings", "element": "home_button_settings", "type": "navigation"}]
    }
  },
  "groups": {
    "main": {
      "name": "Main Flow",
      "color": "#58a6ff",
      "screens": ["01-home", "02-library"]
    }
  }
}
```

**Groups are required for the map view.** Use distinct hex colors for each group.
