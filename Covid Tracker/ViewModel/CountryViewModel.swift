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
    private var sections = [Section]()
    
    var counts: Int {
        sections.count
    }
    
    var letters: [String] {
        sections.map{$0.letter}
    }
    
    func getCountries(completion: @escaping () -> Void) {
        apiCaller.getCountries { result in
            switch result {
            case .success(let countries):
                self.setupDictionary(countries.sorted(by: { $0.name < $1.name }))
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func country(at index: Int) -> Section? {
        sections.element(at: index)
    }
    
    func letter(at index: Int) -> String? {
        letters.element(at: index)
    }
    
    func numberOfRowsInSection(at index: Int) -> Int {
        sections.element(at: index)?.countryNames.count ?? 1
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

extension Array {
    public func element (at index: Int) -> Element? {
        if indices.contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}
