//
//  CountryViewModel.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import Foundation

class CountryViewModel {
    private lazy var apiCaller = ApiCaller()
    public lazy var countryList: [CountryModel] = []
    
    func getCountries() {
        apiCaller.getCountries {[weak self] result in
            switch result {
            case .success(let countries):
                self?.countryList = countries.sorted(by: { $0.name < $1.name })
            case .failure(let error):
                print(error)
            }
        }
    }
}
