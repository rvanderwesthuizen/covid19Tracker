//
//  Cache.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/08/05.
//

import Foundation

class Cache {
    private lazy var apiCaller = ApiCaller()
    
    func getCountries() {
        apiCaller.getCountries { result in
            switch result {
            case .success(let countries):
                self.writeToPlist(data: countries)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func writeToPlist(data countries: [Country]) {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(countries)
            try data.write(to: Constants.countryPlistDataFilePath!)
        } catch {
            print("\(error)")
        }
    }
}
