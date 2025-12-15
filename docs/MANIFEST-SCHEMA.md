# Darwin Manifest Schema

The manifest file (`Screenshots/manifest.json`) tells Darwin which screens exist and which source files affect them.

## Basic Structure

```json
{
  "version": "1.0",
  "description": "Optional description",
  "screens": {
    "screen-id": {
      "name": "Screen Name",
      "description": "Optional description",
      "test": "testMethodName",
      "sources": ["path/to/file.swift"]
    }
  }
}
```

## Fields

### Root Level

| Field | Required | Description |
|-------|----------|-------------|
| `version` | Yes | Schema version (currently "1.0") |
| `description` | No | Human-readable description |
| `screens` | Yes | Map of screen ID → screen config |

### Screen Object

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Human-readable name |
| `description` | No | Detailed description |
| `test` | Yes | XCTest method name (must match exactly) |
| `sources` | Yes | Array of source file paths |

## Screen ID Conventions

Use numbered prefixes for consistent ordering:

```
01-home
02-settings
03-profile
04-detail-empty
05-detail-populated
```

The number prefix ensures screens appear in order in reports.

## Source Paths

Paths are relative to the project root:

```json
"sources": [
  "MyApp/Views/HomeView.swift",
  "MyApp/ViewModels/HomeViewModel.swift",
  "MyApp/Components/HeaderView.swift"
]
```

When ANY file in `sources` changes (via git diff), the screen is marked for recapture.

## Test Method Naming

The `test` field must exactly match your XCTest method name:

```swift
// In ScreenshotTests.swift
func testScreenshot_01_Home() {  // ← This is the test name
    takeScreenshot("01-home")     // ← This is the screen ID
}
```

```json
{
  "01-home": {
    "test": "testScreenshot_01_Home",  // ← Must match exactly
    ...
  }
}
```

## Example: Complete Manifest

```json
{
  "version": "1.0",
  "description": "Screenshots for MyApp",
  "screens": {
    "01-home-empty": {
      "name": "Home (Empty)",
      "description": "Home screen with no content",
      "test": "testScreenshot_01_HomeEmpty",
      "sources": [
        "MyApp/Views/HomeView.swift",
        "MyApp/ViewModels/HomeViewModel.swift"
      ]
    },
    "02-home-populated": {
      "name": "Home (With Items)",
      "description": "Home screen with sample items",
      "test": "testScreenshot_02_HomePopulated",
      "sources": [
        "MyApp/Views/HomeView.swift",
        "MyApp/Views/ItemCell.swift"
      ]
    },
    "03-settings": {
      "name": "Settings",
      "test": "testScreenshot_03_Settings",
      "sources": [
        "MyApp/Views/SettingsView.swift"
      ]
    },
    "04-profile": {
      "name": "Profile",
      "test": "testScreenshot_04_Profile",
      "sources": [
        "MyApp/Views/ProfileView.swift",
        "MyApp/Models/User.swift"
      ]
    }
  }
}
```

## Tips

### Multiple Screens Per View

If one view has multiple states, create separate screens:

```json
"10-modal-loading": { "test": "testScreenshot_10_ModalLoading", ... },
"11-modal-success": { "test": "testScreenshot_11_ModalSuccess", ... },
"12-modal-error":   { "test": "testScreenshot_12_ModalError", ... }
```

### Shared Components

If a component is used in multiple screens, include it in all relevant `sources`:

```json
"01-home": {
  "sources": ["Views/HomeView.swift", "Components/Header.swift"]
},
"02-settings": {
  "sources": ["Views/SettingsView.swift", "Components/Header.swift"]
}
```

When `Header.swift` changes, both screens will be recaptured.

### View Models and Models

Include any files that affect the screen's appearance:

```json
"sources": [
  "Views/DetailView.swift",      // The view itself
  "ViewModels/DetailViewModel.swift",  // Data logic
  "Models/Item.swift",           // Data model
  "Styles/Theme.swift"           // Styling
]
```
