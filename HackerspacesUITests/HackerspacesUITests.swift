//
//  HackerspacesUITests.swift
//  HackerspacesUITests
//
//  Created by zephyz on 13.08.17.
//  Copyright © 2017 Fixme. All rights reserved.
//

import XCTest

class HackerspacesUITests: XCTestCase {


    // Setting up the test environement using solution from https://stackoverflow.com/a/34963630
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        let app = XCUIApplication()

        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
