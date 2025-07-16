//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by mnabdrakhmanov on 08.02.2025.
//

import XCTest

// тесты флакают
final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UITest"]
        app.launch()
    }
    
    func testAuth() throws {
        let loginButton = app.buttons["Authenticate"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        XCTAssertTrue(webView.isHittable)
        sleep(3)
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("")
        
        sleep(2)
        
        // из-за того что не может свайпнуть, приходится костылить
        let start = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        let finish = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        start.press(forDuration: 0.01, thenDragTo: finish)
        // не может свайпнуть
        webView.swipeUp()
        
        sleep(2)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        // иногда вводит только один символ в поле с паролем
        passwordTextField.tap()
        passwordTextField.press(forDuration: 0.5)
        sleep(1)
        passwordTextField.typeText("")
        //XCTAssertEqual(passwordTextField.value as? String, "••••••••••")
        
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        
        let likeButton = cellToLike.buttons["Like"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        sleep(2)
        likeButton.tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1) // Zoom in
        image.pinch(withScale: 0.5, velocity: -1) // Zoom out
        
        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(5)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Marsel Marso"].exists)
        XCTAssertTrue(app.staticTexts["@marsel132313"].exists)
        
        app.buttons["logout"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        sleep(2)
        
        let loginButton = app.buttons["Authenticate"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
    }
}
