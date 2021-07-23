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
    
    func testIfCountryViewModelDoesSetUserDefaults() {
        let countryViewModel = CountryViewModel()
        let defaultCountry = CountryModel(name: "Russian Federation", slug: "russia")
        var country: CountryModel?
        countryViewModel.setDefaults(defaultCountry)
        
        if let defaultName = UserDefaults().string(forKey: Constants().defaultCountryNameKey), let defaultSlug = UserDefaults().string(forKey: Constants().defaultCountrySlugKey) {
            country = CountryModel(name: defaultName, slug: defaultSlug)
        } else {
            XCTAssertThrowsError(print("defaultName or defaultString returned nil"))
        }
        
        XCTAssertEqual(country!.name, defaultCountry.name)
    }
}
