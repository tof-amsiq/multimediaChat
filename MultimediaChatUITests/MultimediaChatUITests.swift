//
//  MultimediaChatUITests.swift
//  MultimediaChatUITests
//
//  Created by Tobias Frantsen on 20/12/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import XCTest

class MultimediaChatUITests: XCTestCase {
var app: XCUIApplication!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginButton() {
        app.launch()
        app.textFields.element.tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        app.keys["s"].tap()
        app.keys["t"].tap()
        app.keyboards.buttons["Return"].tap()
        
        app.buttons["Join Chat "].tap()

    }

}