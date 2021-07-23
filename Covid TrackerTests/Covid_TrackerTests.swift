//
//  Covid_TrackerTests.swift
//  Covid TrackerTests
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import XCTest
@testable import Covid_Tracker

class Covid_TrackerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIfCountryViewModelGetCountriesFunctionReturnsAListOf248() {
        let countryViewModel = CountryViewModel()
        countryViewModel.getCountries { countries in
            XCTAssertEqual(countries.count, 248)
        }
    }
}
