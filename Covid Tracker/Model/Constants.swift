//
//  Constants.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import Foundation

enum Constants {
    static let allCountriesURL = URL(string: "https://api.covid19api.com/countries")
    static let baseURLString = "https://api.covid19api.com/country/"
    static let defaultCountryNameKey = "DefaultCountryName"
    static let defaultCountrySlugKey = "DefaultCountrySlug"
    static let countriesPlist = "Countries.plist"
}
