//
//  CovidDataViewModelTests.swift
//  Covid TrackerTests
//
//  Created by Ruan van der Westhuizen on 2021/08/05.
//

import XCTest
@testable import Covid_Tracker

class CovidDataViewModelTests: XCTestCase {
    let covidDataViewModel = CovidDataViewModel()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIfCovidDataViewModelSetDoesOnlyContain31Values() {
        covidDataViewModel.getData {
            XCTAssertEqual(self.covidDataViewModel.set.count, 31)
        }
    }
    
    func testThatTheDatesDoNotContainTheTime() {
        covidDataViewModel.getData {
            self.covidDataViewModel.setupDates(at: 1)
            self.covidDataViewModel.dates.forEach { date in
                if date.contains("T00:00:00Z") {
                    XCTFail()
                }
            }
        }
    }
}
