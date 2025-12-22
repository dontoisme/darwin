# Darwin Visual Documentation Patterns

This project uses Darwin for visual regression tracking and app flow documentation.
Follow these patterns for AI-generated code to work seamlessly with Darwin.

## Setting Up Darwin (If Not Initialized)

When a user asks to set up Darwin or initialize visual regression testing:

```bash
darwin init --ai-interactive
```

This outputs structured questions. Present them to the user using AskUserQuestion:
- Scheme selection (from Xcode project)
- Simulator selection (from available devices)
- Automation mode (Autopilot/Guided/Manual)

Then run with their selections:
```bash
darwin init --ai --scheme <scheme> --destination 'platform=iOS Simulator,name=<device>' --mode <mode>
```

After init completes, follow the "AI ASSISTANT" handoff instructions in the output to:
1. Read and update Screenshots/manifest.json with flows_to connections
2. Add navigation logic to the generated test stubs
3. Run `darwin capture --baseline`

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

## Screenshot Output Directory

Darwin automatically detects where to save screenshots using this priority:

1. `SCREENSHOT_OUTPUT_DIR` environment variable (set by Darwin CLI)
2. `PROJECT_DIR` or `SRCROOT` environment variables
3. **Fallback detection**: Walks up from test bundle location looking for project root indicators (`.git`, `.xcodeproj`, `.xcworkspace`, `Package.swift`) and saves to `<project_root>/Screenshots/captures/`

The fallback is essential because xcodebuild doesn't propagate build settings to the test process environment. This ensures screenshots save to the filesystem even when environment variables aren't available.

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

## Manifest Structure

The manifest organizes screens into **groups** for the map view. Groups represent logical areas of your app (e.g., "Onboarding", "Settings", "Main Flow").

When adding new screens, update `Screenshots/manifest.json`:
1. Add screen definition to `screens` with `sources` array and `flows_to` connections
2. Add the screen ID to the appropriate group in `groups`
3. If it's a new area of the app, create a new group with a distinct color

```json
{
  "screens": {
    "01-home": {
      "name": "Home",
      "test": "testScreenshot_01_Home",
      "sources": ["Sources/Views/HomeView.swift"],
      "flows_to": [
        {"target": "02-settings", "element": "home_button_settings", "type": "navigation"}
      ]
    },
    "02-settings": {
      "name": "Settings",
      "test": "testScreenshot_02_Settings",
      "sources": ["Sources/Views/SettingsView.swift"],
      "flows_to": []
    },
    "10-profile-logged-in": {
      "name": "Profile (Logged In)",
      "test": "testScreenshot_10_ProfileLoggedIn",
      "requires_firebase": true,
      "sources": ["Sources/Views/ProfileView.swift"],
      "flows_to": []
    }
  },
  "groups": {
    "main": {
      "name": "Main Flow",
      "color": "#58a6ff",
      "screens": ["01-home", "02-library"]
    },
    "settings": {
      "name": "Settings",
      "color": "#f78166",
      "screens": ["02-settings", "03-settings-theme"]
    }
  }
}
```

**Groups are required for the map view.** Use distinct colors for each group (hex format).

### Firebase-Dependent Screens

For screens that require Firebase authentication (login state, user data, etc.), add `requires_firebase: true`:

```json
"12-profile-no-guild": {
  "name": "Profile - No Guild",
  "test": "testScreenshot_12_profile_no_guild",
  "requires_firebase": true,
  "sources": ["Sources/Views/ProfileView.swift"]
}
```

Darwin will detect Firebase and check if emulators are running before capture. If emulators are not running, screens with `requires_firebase: true` will be skipped with a warning.

To capture Firebase-dependent screens:
1. Start Firebase emulators: `firebase emulators:start --only auth,firestore`
2. Run: `darwin capture --firebase`
