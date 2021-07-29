//
//  CountryViewModel.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import Foundation

class CountryViewModel {
    private lazy var apiCaller = ApiCaller()
    private lazy var defaults = UserDefaults()
    public var countryList: [CountryModel] = []
    public var sections = [Section]()
    
    func getCountries(completion: @escaping ([Section]) -> Void) {
        apiCaller.getCountries { result in
            switch result {
            case .success(let countries):
                self.setupDictionary(countries.sorted(by: { $0.name < $1.name }))
                completion(self.sections)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupDictionary(_ countries: [CountryModel]) {
        let groupedDictionary = Dictionary(grouping: countries, by: {String($0.name.prefix(1))})
        let keys = groupedDictionary.keys.sorted()
        sections = keys.map{ Section(letter: $0, countryNames: groupedDictionary[$0]!) }
    }
    
    func setDefaults(_ country: CountryModel) {
        defaults.set(country.name, forKey: Constants.defaultCountryNameKey)
        defaults.set(country.slug, forKey: Constants.defaultCountrySlugKey)
    }
    
    struct Section {
        let letter: String
        let countryNames: [CountryModel]
    }
}
