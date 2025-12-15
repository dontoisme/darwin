//
//  BaseScreenshotTests.swift
//  Darwin - Base class for screenshot tests
//
//  Subclass this in your UI test target:
//
//  class ScreenshotTests: BaseScreenshotTests {
//      func testScreenshot_01_Home() {
//          // Navigate to home screen
//          takeScreenshot("01-home")
//      }
//  }
//

import XCTest

class BaseScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    /// Whether to reset app state before each test
    var shouldResetState: Bool { true }

    /// Launch arguments to pass to the app
    var launchArguments: [String] { [] }

    /// Launch environment variables
    var launchEnvironment: [String: String] { [:] }

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Fail fast - don't continue after first failure
        continueAfterFailure = false

        app = XCUIApplication()

        // Add launch arguments
        for arg in launchArguments {
            app.launchArguments.append(arg)
        }

        // Add launch environment
        for (key, value) in launchEnvironment {
            app.launchEnvironment[key] = value
        }

        // Reset state if needed (you might use --reset-state launch arg)
        if shouldResetState {
            app.launchArguments.append("--reset-state")
        }

        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Navigation Helpers

    /// Wait for an element to exist
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    /// Wait for element to exist, then take screenshot
    func waitAndScreenshot(_ element: XCUIElement, name: String, timeout: TimeInterval = 5) {
        if element.waitForExistence(timeout: timeout) {
            takeScreenshot(name)
        } else {
            XCTFail("Element not found for screenshot: \(name)")
        }
    }

    /// Tap element by accessibility identifier
    func tap(_ identifier: String) {
        let element = app.descendants(matching: .any)[identifier]
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Element not found: \(identifier)")
        element.tap()
    }

    /// Wait for and tap element
    func waitAndTap(_ identifier: String, timeout: TimeInterval = 5) {
        let element = app.descendants(matching: .any)[identifier]
        if element.waitForExistence(timeout: timeout) {
            element.tap()
        } else {
            XCTFail("Element not found for tap: \(identifier)")
        }
    }
}
