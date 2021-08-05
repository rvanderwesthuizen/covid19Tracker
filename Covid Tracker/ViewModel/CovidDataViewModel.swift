//
//  CovidDataViewModel.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/29.
//

import Foundation

class CovidDataViewModel {
    enum statusSelector {
        case active
        case confirmed
        case deaths
        case recovered
    }
    
    private let defaults = UserDefaults()
    
    private lazy var apiCaller = ApiCaller()
    private var data: [CovidDataResult] = []
    var dates: [String] = []
    
    var set: [CovidDataResult] {
        data.suffix(31)
    }
    
    var selectedCountryText: String {
        switch scope {
        case .defaultCountry(let country): return country.name
        case .country(let country): return country.name
        }
    }
    
    var selectedStatus: statusSelector = .active
    
    var scope: ApiCaller.DataScope = .defaultCountry(CountryModel(name: "South Africa", slug: "south-africa"))
    
    func graphDataInstance(at index: Int) -> Int{
        switch selectedStatus {
        case .active:
            return set[index].active
        case .confirmed:
            return set[index].confirmed
        case .deaths:
            return set[index].deaths
        case .recovered:
            return set[index].recovered
        }
    }
    
    func dataSetLabel() -> String {
        switch selectedStatus {
        case .active:
            return "Active cases for: \(selectedCountryText)"
        case .confirmed:
            return "Confirmed cases for: \(selectedCountryText)"
        case .deaths:
            return "Deaths for: \(selectedCountryText)"
        case .recovered:
            return "Recoveries for: \(selectedCountryText)"
        }
    }
    
    func setupDates(at index: Int) {
        dates.append(set[index].date.replacingOccurrences(of: "T00:00:00Z", with: ""))
    }
    
    func checkForDefault() {
        if let defaultName = defaults.string(forKey: Constants.defaultCountryNameKey), let defaultSlug = defaults.string(forKey: Constants.defaultCountrySlugKey) {
            scope = .defaultCountry(CountryModel(name: defaultName, slug: defaultSlug))
        }
    }
    
    func getData(completion: @escaping () -> Void) {
        apiCaller.getCovidData(for: scope) {result in
            switch result {
            case .success(let data):
                self.data = data
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
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
    
    func writeToPlist(data countries: [CountryModel]) {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(countries)
            try data.write(to: Constants.countryPlistDataFilePath!)
        } catch {
            print("\(error)")
        }
    }
}
