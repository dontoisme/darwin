# Darwin Visual Documentation Patterns

This iOS project uses Darwin for visual regression tracking.

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

Remind user to update Screenshots/manifest.json with:
- Screen definition including sources array
- flows_to connections with element identifiers

```json
{
  "01-home": {
    "name": "Home",
    "test": "testScreenshot_01_Home",
    "sources": ["Sources/Views/HomeView.swift"],
    "flows_to": [{ "target": "02-settings", "element": "home_button_settings" }]
  }
}
```
