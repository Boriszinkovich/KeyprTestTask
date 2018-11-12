//
//  KeyprTestTaskTests.swift
//  KeyprTestTaskTests
//
//  Created by Borys Zinkovych on 11/8/18.
//  Copyright © 2018 bzink. All rights reserved.
//

import XCTest
import CoreData
@testable import KeyprTestTask

class KeyprTestTaskTests: XCTestCase {

    var loadStarted: Bool = false
    var loadSuccessful: Bool = false
    var expectation: XCTestExpectation?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWeatherService() {
        let service = WeatherService(api: APIService())
        service.delegate = self
        let loads = service.forceLoadWeather()
        XCTAssertTrue(loads)
        
        XCTAssertTrue(self.loadStarted)
        self.expectation = self.expectation(description: "Some")
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertTrue(self.loadSuccessful)
        let entities = getWeatherEntities()
        XCTAssertTrue(entities.count == 3)
    }
    
    func getWeatherEntities() -> [Weather] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(request)
            guard let cityResult = result as? [Weather] else {
                fatalError("DB fatal error")
            }
            return cityResult
        } catch _ {
            fatalError("DB fatal error")
        }
    }

}

extension KeyprTestTaskTests: WeatherServiceDelegate {
    
    func weatherServiceDidFinishLoading() {
        self.loadSuccessful = true
        self.expectation?.fulfill()
    }
    
    func weatherServiceDidStartLoading() {
        self.loadStarted = true
    }
    
    func weatherServiceFailedLoading(error: WeatherServiceError) {
        
    }
}
