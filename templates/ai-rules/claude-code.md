# Darwin Visual Documentation Patterns

This project uses Darwin for visual regression tracking and app flow documentation.
Follow these patterns for AI-generated code to work seamlessly with Darwin.

## SwiftUI Views

### Accessibility Identifiers (Required)

Add `.accessibilityIdentifier()` to ALL interactive elements:
- Buttons, NavigationLinks, toggles, text fields, list rows
- Naming convention: `screen_element_action` (snake_case)
- Examples: `home_button_settings`, `settings_row_theme`, `profile_toggle_notifications`

```swift
Button("Settings") { ... }
    .accessibilityIdentifier("home_button_settings")

Toggle("Notifications", isOn: $enabled)
    .accessibilityIdentifier("settings_toggle_notifications")
```

### Navigation Patterns (Preferred)

Use NavigationLink with typed values - Darwin can parse these automatically:

```swift
// Preferred - Darwin can parse
NavigationLink("Theme", value: SettingsScreen.theme)
    .accessibilityIdentifier("settings_row_theme")

// Works but harder to parse
NavigationLink { ThemeView() } label: { Text("Theme") }
    .accessibilityIdentifier("settings_row_theme")
```

### Screen Identifiers Enum (If Present)

If this project has a `ScreenIdentifiers` enum, use it for consistency.
Otherwise, suggest creating one for centralized identifier management:

```swift
enum ScreenIdentifiers {
    enum Home {
        static let buttonSettings = "home_button_settings"
        static let buttonProfile = "home_button_profile"
    }
    enum Settings {
        static let rowTheme = "settings_row_theme"
        static let toggleNotifications = "settings_toggle_notifications"
    }
}
```

## XCUITests for Darwin

When writing screenshot tests:
- Use `takeScreenshotWithElements("XX-screen-name", app: app)` for captures
- Prefix names with two-digit ordering: `01-home`, `02-settings`
- Navigate using accessibility identifiers

```swift
func testScreenshot_01_Home() {
    let app = XCUIApplication()
    app.launch()
    takeScreenshotWithElements("01-home", app: app)
}

func testScreenshot_02_Settings() {
    let app = XCUIApplication()
    app.launch()
    app.buttons["home_button_settings"].tap()
    takeScreenshotWithElements("02-settings", app: app)
}
```

## Manifest Sync

When adding new screens, remind user to update `Screenshots/manifest.json`:
- Add screen definition with `sources` array pointing to Swift files
- Add `flows_to` with element identifiers for navigation connections

```json
{
  "screens": {
    "01-home": {
      "name": "Home",
      "test": "testScreenshot_01_Home",
      "sources": ["Sources/Views/HomeView.swift"],
      "flows_to": [
        {
          "target": "02-settings",
          "element": "home_button_settings",
          "type": "navigation"
        }
      ]
    }
  }
}
```
