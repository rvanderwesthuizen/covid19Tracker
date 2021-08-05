//
//  Covid_TrackerTests.swift
//  Covid TrackerTests
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import XCTest
@testable import Covid_Tracker

class Covid_TrackerTests: XCTestCase {
    let countryViewModel = CountryViewModel()
    let covidDataViewModel = CovidDataViewModel()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: - CountryViewModelTests
    func testIfCountryViewModelGetCountriesFunctionCreateASectionsListOf248() {
        countryViewModel.getCountries {
            XCTAssertEqual(self.countryViewModel.counts, 248)
        }
    }
    
    func testIfCountryViewModelDoesSetUserDefaults() {
        let defaultCountry = Country(name: "Russian Federation", slug: "russia")
        var country: Country?
        countryViewModel.setDefaults(defaultCountry)
        
        let defaultName = UserDefaults().string(forKey: Constants.defaultCountryNameKey)
        let defaultSlug = UserDefaults().string(forKey: Constants.defaultCountrySlugKey)
        country = Country(name: defaultName!, slug: defaultSlug!)
        
        XCTAssertTrue(country!.name == defaultCountry.name && country?.slug == defaultCountry.slug)
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
    
    //MARK: - CovidDataViewModelTests
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
