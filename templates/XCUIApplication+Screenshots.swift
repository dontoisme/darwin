//
//  XCUIApplication+Screenshots.swift
//  Darwin - Screenshot capture helpers for UI tests
//
//  Add this file to your UI test target.
//  Usage: takeScreenshot("01-home") in any XCTestCase
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

    /// Take a screenshot with a delay (for animations)
    func takeScreenshotAfterDelay(_ name: String, delay: TimeInterval = 1.0) {
        Thread.sleep(forTimeInterval: delay)
        takeScreenshot(name)
    }

    private func saveScreenshotToFile(_ image: UIImage, name: String, folder: String) {
        guard let data = image.pngData() else {
            print("[Darwin] Failed to create PNG data for: \(name)")
            return
        }

        // Get screenshot output directory from environment
        // Darwin sets SCREENSHOT_OUTPUT_DIR when running tests
        let screenshotDir: String
        if let outputDir = ProcessInfo.processInfo.environment["SCREENSHOT_OUTPUT_DIR"] {
            // Direct output directory from darwin capture script
            screenshotDir = outputDir
        } else if let envDir = ProcessInfo.processInfo.environment["PROJECT_DIR"] {
            screenshotDir = "\(envDir)/\(folder)"
        } else if let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] {
            screenshotDir = "\(srcRoot)/\(folder)"
        } else {
            // Fallback: can't determine directory
            print("[Darwin] Warning: Could not determine screenshot directory.")
            print("[Darwin] Set PROJECT_DIR or SRCROOT environment variable.")
            return
        }

        let fileManager = FileManager.default

        // Create directory if needed
        if !fileManager.fileExists(atPath: screenshotDir) {
            do {
                try fileManager.createDirectory(
                    atPath: screenshotDir,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print("[Darwin] Created directory: \(screenshotDir)")
            } catch {
                print("[Darwin] Failed to create directory: \(error)")
                return
            }
        }

        let filePath = "\(screenshotDir)/\(name).png"

        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            print("[Darwin] Saved: \(filePath)")
        } catch {
            print("[Darwin] Failed to save: \(error)")
        }
    }
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
