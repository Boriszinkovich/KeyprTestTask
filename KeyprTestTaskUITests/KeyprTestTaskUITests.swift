//
//  KeyprTestTaskUITests.swift
//  KeyprTestTaskUITests
//
//  Created by Borys Zinkovych on 11/8/18.
//  Copyright © 2018 bzink. All rights reserved.
//

import XCTest

class KeyprTestTaskUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleLaunch() {
        let element = XCUIApplication().otherElements[UIAccessibilityIdentifiers.keyMainVCId]
        waitForElementAppearance(interval: 5, element: element)
        XCTAssertTrue(element.exists)
        // check if three cities are on the screen
        let cells = XCUIApplication().cells.matching(identifier: UIAccessibilityIdentifiers.keyMainVCCellId)
        XCTAssertTrue(cells.count == 3)
        // wait until data will be loaded
        // TODO: replace sleep with waitForPredicate
        sleep(5)
        let cell = cells.firstMatch
        let temp = cell.staticTexts[UIAccessibilityIdentifiers.keyTemperatureLabelId].firstMatch
        XCTAssertTrue(temp.exists)
        let tempValue = temp.label
        XCTAssertFalse(tempValue == "-||-" || tempValue == "")
    }
    
    func waitForElementAppearance(interval: TimeInterval, element: XCUIElement) {
        let predicate = NSPredicate(format: "exists == 1")
        expectation(for: predicate, evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: interval, handler: nil)
    }
}
