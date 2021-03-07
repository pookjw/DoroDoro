//
//  DoroDoroUITests.swift
//  DoroDoroUITests
//
//  Created by Jinwoo Kim on 2/26/21.
//

import XCTest
@testable import DoroDoro

final internal class DoroDoroUITests: XCTestCase {
    override internal func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    @discardableResult
    private func runApp() -> XCUIApplication {
        let app: XCUIApplication = .init()
        app.launch()
        return app
    }
    
    internal func testRunningApp() {
        runApp()
    }
    
    internal func testSearch() {
        let app: XCUIApplication = runApp()
        let searchField: XCUIElement = app.searchFields[AccessibilityIdentifiers.SearchVC.searchField]
        searchField.tap()
        searchField.typeText("테헤란로 4길 14")
        app.keyboards.buttons["Search"].tap()
        
        let result: XCUIElement = app.otherElements["서울특별시 강남구 테헤란로4길 14 (역삼동)"]
        XCTAssertTrue(result.waitForExistence(timeout: 10))
        result.tap()
    }
}
