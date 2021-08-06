//
//  CovidDataViewModel.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/29.
//

import Foundation
import CoreLocation
import MapKit

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
    var found: Bool = false
    
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
    
    var scope: ApiCaller.DataScope = .defaultCountry(Country(name: "South Africa", slug: "south-africa"))
    
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
            return "Active cases for: ".localized() + selectedCountryText
        case .confirmed:
            return "Confirmed cases for: ".localized() + selectedCountryText
        case .deaths:
            return "Deaths for: ".localized() + selectedCountryText
        case .recovered:
            return "Recoveries for: ".localized() + selectedCountryText
        }
    }
    
    func setupDates(at index: Int) {
        dates.append(set[index].date.replacingOccurrences(of: "T00:00:00Z", with: ""))
    }
    
    func checkForDefault() {
        if let defaultName = defaults.string(forKey: Constants.defaultCountryNameKey), let defaultSlug = defaults.string(forKey: Constants.defaultCountrySlugKey) {
            scope = .defaultCountry(Country(name: defaultName, slug: defaultSlug))
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
    
    func geoLocation(from location: CLLocation, completion: @escaping () -> Void) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if error == nil {
                guard let country = placemarks?.first?.country else { return }
                self.setDefaultBasedOnLocation(country)
                completion()
            } else {
                print(error!)
            }
        }
    }
    
    func setDefaultBasedOnLocation(_ location: String) {
        if let data = try? Data(contentsOf: Constants.countryPlistDataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                let countries = try decoder.decode([Country].self, from: data)
                countries.forEach({ country in
                    if country.name == location {
                        found = true
                        scope = .defaultCountry(Country(name: country.name, slug: country.slug))
                    }
                })
                if !found {
                    checkForDefault()
                }
            } catch {
                print("\(error)")
            }
        }
    }
}
