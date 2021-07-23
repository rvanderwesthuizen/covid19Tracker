//
//  CountryViewModel.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import Foundation

class CountryViewModel {
    private lazy var apiCaller = ApiCaller()
    public var countryList: [CountryModel] = []
    
    func getCountries(completion: @escaping ([CountryModel]) -> Void) {
        apiCaller.getCountries {result in
            switch result {
            case .success(let countries):
                completion(countries)
            case .failure(let error):
                print(error)
                return
            }
        }
    }
}
