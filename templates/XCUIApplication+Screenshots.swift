//
//  XCUIApplication+Screenshots.swift
//  Darwin - Screenshot capture helpers for UI tests
//
//  Add this file to your UI test target.
//  Usage: takeScreenshot("01-home") in any XCTestCase
//         takeScreenshotWithElements("01-home", app: app) to also capture element coordinates
//

import XCTest

extension XCTestCase {

    /// Take a screenshot and save it to the Screenshots folder
    /// - Parameters:
    ///   - name: The screenshot filename (without extension)
    ///   - folder: The folder name within the project (default: "Screenshots")
    func takeScreenshot(_ name: String, in folder: String = "Screenshots") {
        // Small delay to ensure UI is fully rendered
        Thread.sleep(forTimeInterval: 0.5)

        let screenshot = XCUIScreen.main.screenshot()

        // Attach to test results (visible in Xcode)
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Also save to filesystem for git tracking
        saveScreenshotToFile(screenshot.image, name: name, folder: folder)
    }

    /// Take a screenshot AND capture element coordinates for tap target mapping
    /// - Parameters:
    ///   - name: The screenshot filename (without extension)
    ///   - app: The XCUIApplication to query for element coordinates
    ///   - folder: The folder name within the project (default: "Screenshots")
    func takeScreenshotWithElements(_ name: String, app: XCUIApplication, in folder: String = "Screenshots") {
        // Small delay to ensure UI is fully rendered
        Thread.sleep(forTimeInterval: 0.5)

        // Capture element coordinates BEFORE screenshot (in case UI changes)
        let elementData = captureElementCoordinates(from: app)

        let screenshot = XCUIScreen.main.screenshot()

        // Attach to test results (visible in Xcode)
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Save screenshot to filesystem
        saveScreenshotToFile(screenshot.image, name: name, folder: folder)

        // Save element coordinates alongside screenshot
        saveElementCoordinates(elementData, name: name, folder: folder)
    }

    /// Capture coordinates for all accessible elements with identifiers
    private func captureElementCoordinates(from app: XCUIApplication) -> DarwinElementData {
        var elements: [String: DarwinElementFrame] = [:]

        // Query all descendants with accessibility identifiers
        let allElements = app.descendants(matching: .any).allElementsBoundByIndex

        for element in allElements {
            // Only capture elements with non-empty identifiers that exist
            guard element.exists,
                  !element.identifier.isEmpty else { continue }

            let frame = element.frame

            // Skip elements with zero or invalid frames
            guard frame.width > 0, frame.height > 0,
                  frame.origin.x.isFinite, frame.origin.y.isFinite else { continue }

            elements[element.identifier] = DarwinElementFrame(
                x: frame.origin.x,
                y: frame.origin.y,
                width: frame.width,
                height: frame.height
            )
        }

        // Get device/screen info for coordinate scaling
        let screenBounds = XCUIScreen.main.screenshot().image.size

        return DarwinElementData(
            device: DarwinDeviceInfo(
                width: screenBounds.width,
                height: screenBounds.height,
                scale: UIScreen.main.scale
            ),
            elements: elements
        )
    }

    /// Save element coordinates to JSON file
    private func saveElementCoordinates(_ data: DarwinElementData, name: String, folder: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let jsonData = try? encoder.encode(data),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("[Darwin] Failed to encode element data for: \(name)")
            return
        }

        saveToFile(jsonString, name: "\(name)_elements", extension: "json", folder: folder)
    }

    /// Generic file saving helper
    private func saveToFile(_ content: String, name: String, extension ext: String, folder: String) {
        guard let data = content.data(using: .utf8) else { return }

        let screenshotDir = getOutputDirectory(folder: folder)
        guard let dir = screenshotDir else { return }

        let filePath = "\(dir)/\(name).\(ext)"

        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            print("[Darwin] Saved: \(filePath)")
        } catch {
            print("[Darwin] Failed to save \(filePath): \(error)")
        }
    }

    /// Get the output directory, creating if needed
    private func getOutputDirectory(folder: String) -> String? {
        let screenshotDir: String
        if let outputDir = ProcessInfo.processInfo.environment["SCREENSHOT_OUTPUT_DIR"],
           !outputDir.isEmpty {
            screenshotDir = outputDir
        } else if let envDir = ProcessInfo.processInfo.environment["PROJECT_DIR"],
                  !envDir.isEmpty {
            screenshotDir = "\(envDir)/\(folder)"
        } else if let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"],
                  !srcRoot.isEmpty {
            screenshotDir = "\(srcRoot)/\(folder)"
        } else if let projectRoot = detectProjectRoot() {
            // Fallback: detect project root from test bundle location
            screenshotDir = "\(projectRoot)/Screenshots/captures"
            print("[Darwin] Using detected project root: \(projectRoot)")
        } else {
            print("[Darwin] Warning: Could not determine output directory.")
            return nil
        }

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: screenshotDir) {
            do {
                try fileManager.createDirectory(
                    atPath: screenshotDir,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("[Darwin] Failed to create directory: \(error)")
                return nil
            }
        }

        return screenshotDir
    }

    /// Detect project root by walking up from test bundle location
    /// Looks for common project indicators: .git, .xcodeproj, .xcworkspace, Package.swift
    private func detectProjectRoot() -> String? {
        // Get the test bundle location
        let testBundle = Bundle(for: type(of: self))
        var currentPath = testBundle.bundleURL.deletingLastPathComponent()
        let fileManager = FileManager.default

        // Walk up the directory tree looking for project root indicators
        let projectIndicators = [".git", "Package.swift"]
        let projectExtensions = ["xcodeproj", "xcworkspace"]

        for _ in 0..<20 { // Safety limit to prevent infinite loops
            let path = currentPath.path

            // Check for exact file/folder matches
            for indicator in projectIndicators {
                if fileManager.fileExists(atPath: "\(path)/\(indicator)") {
                    return path
                }
            }

            // Check for project/workspace files by extension
            if let contents = try? fileManager.contentsOfDirectory(atPath: path) {
                for item in contents {
                    for ext in projectExtensions {
                        if item.hasSuffix(".\(ext)") {
                            return path
                        }
                    }
                }
            }

            // Move up one directory
            let parent = currentPath.deletingLastPathComponent()
            if parent.path == currentPath.path {
                // Reached filesystem root
                break
            }
            currentPath = parent
        }

        return nil
    }

    /// Take a screenshot with a delay (for animations)
    func takeScreenshotAfterDelay(_ name: String, delay: TimeInterval = 1.0) {
        Thread.sleep(forTimeInterval: delay)
        takeScreenshot(name)
    }

    /// Take a screenshot with elements after a delay (for animations)
    func takeScreenshotWithElementsAfterDelay(_ name: String, app: XCUIApplication, delay: TimeInterval = 1.0) {
        Thread.sleep(forTimeInterval: delay)
        takeScreenshotWithElements(name, app: app)
    }

    private func saveScreenshotToFile(_ image: UIImage, name: String, folder: String) {
        guard let data = image.pngData() else {
            print("[Darwin] Failed to create PNG data for: \(name)")
            return
        }

        guard let dir = getOutputDirectory(folder: folder) else { return }

        let filePath = "\(dir)/\(name).png"

        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            print("[Darwin] Saved: \(filePath)")
        } catch {
            print("[Darwin] Failed to save: \(error)")
        }
    }
}

// MARK: - Darwin Element Data Models

/// Device information for coordinate scaling
struct DarwinDeviceInfo: Codable {
    let width: CGFloat
    let height: CGFloat
    let scale: CGFloat
}

/// Frame coordinates for a UI element
struct DarwinElementFrame: Codable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

/// Complete element data for a screenshot
struct DarwinElementData: Codable {
    let device: DarwinDeviceInfo
    let elements: [String: DarwinElementFrame]
}

// MARK: - Screenshot Naming Helpers

extension XCTestCase {

    /// Generate a timestamped screenshot name
    func timestampedName(_ baseName: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = formatter.string(from: Date())
        return "\(baseName)_\(timestamp)"
    }

    /// Generate a versioned screenshot name based on git commit
    func versionedName(_ baseName: String) -> String {
        if let commit = ProcessInfo.processInfo.environment["GIT_COMMIT"]?.prefix(7) {
            return "\(baseName)_\(commit)"
        }
        return baseName
    }
}
