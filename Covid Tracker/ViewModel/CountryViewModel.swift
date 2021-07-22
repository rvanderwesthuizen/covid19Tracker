//
//  CountryViewModel.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import Foundation

class CountryViewModel {
    
    let name: String
    let slug: String
    
    init(country: CountryModel) {
        self.name = country.country
        self.slug = country.slug
    }
}
