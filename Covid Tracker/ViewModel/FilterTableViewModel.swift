//
//  CountryViewModel.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/22.
//

import Foundation

class FilterTableViewModel {
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
        if let data = try? Data(contentsOf: Constants.countryPlistDataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                self.setupDictionary(try decoder.decode([Country].self, from: data).sorted(by: { $0.name < $1.name }))
                completion()
            } catch {
                print("\(error)")
            }
        } else {
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
    
    private func setupDictionary(_ countries: [Country]) {
        let groupedDictionary = Dictionary(grouping: countries, by: {String($0.name.prefix(1))})
        let keys = groupedDictionary.keys.sorted()
        sections = keys.map{ Section(letter: $0, countryNames: groupedDictionary[$0]!) }
    }
    
    struct Section {
        let letter: String
        let countryNames: [Country]
    }
}
