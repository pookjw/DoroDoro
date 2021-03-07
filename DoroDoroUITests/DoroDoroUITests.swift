//
//  DoroDoroUITests.swift
//  DoroDoroUITests
//
//  Created by Jinwoo Kim on 2/26/21.
//

import XCTest

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
        
    }
}
