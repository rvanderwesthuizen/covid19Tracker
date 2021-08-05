//
//  Covid_TrackerTests.swift
//  Covid TrackerTests
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import XCTest
@testable import Covid_Tracker

class FilterTableViewModelTests: XCTestCase {
    let countryViewModel = FilterTableViewModel()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIfCountryViewModelGetCountriesFunctionCreateASectionsListOf248() {
        countryViewModel.getCountries {
            XCTAssertEqual(self.countryViewModel.counts, 248)
        }
    }
    
    func testThereAreNoDuplicatesInLetters() {
        var prevItem = ""
        
        for item in countryViewModel.letters {
            if prevItem == item {
                XCTFail()
            }
            
            prevItem = item
        }
    }
    
    func testForFailureWhenIndexIsOutOfBounds() {
        if let _ = countryViewModel.country(at: -1), let _ = countryViewModel.letter(at: -1) {
            XCTFail()
        }
    }
    
}
