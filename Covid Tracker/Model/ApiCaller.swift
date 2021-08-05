//
//  ApiCaller.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import Foundation

struct ApiCaller {
    
    enum DataScope {
        case defaultCountry(Country)
        case country(Country)
    }
    
    public mutating func getCountries(completion: @escaping (Result<[Country], Error>) -> Void){
        if let url = Constants.allCountriesURL {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    return
                }
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode([Country].self, from: safeData)
                        let countries = result
                        completion(.success(countries))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
    
    public mutating func getCovidData(for scope: DataScope, completion: @escaping (Result<[CovidDataResult], Error>) -> Void){
        let stringURL: String
        switch scope {
        case .defaultCountry(let country): stringURL = "\(Constants.baseURLString)\(country.slug)"
        case .country(let country): stringURL = "\(Constants.baseURLString)\(country.slug)"
        }
        if let url = URL(string: stringURL) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode([CovidDataResult].self, from: safeData)
                        let data: [CovidDataResult] = result
                        completion(.success(data))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
}

//MARK: - Models

struct Country: Codable {
    let name: String
    let slug: String
    
    private enum CodingKeys: String, CodingKey {
        case name = "Country"
        case slug = "Slug"
    }
}

struct CovidDataResult: Codable {
    let confirmed: Int
    let deaths: Int
    let recovered: Int
    let active: Int
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case confirmed = "Confirmed"
        case deaths = "Deaths"
        case recovered = "Recovered"
        case active = "Active"
        case date = "Date"
    }
}
