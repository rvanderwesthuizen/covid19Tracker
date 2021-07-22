//
//  ApiCaller.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import Foundation

struct ApiCaller {
    private lazy var constants = Constants()
    
    enum DataScope {
        case defaultCountry(CountryModel)
        case country(CountryModel)
    }
    
    public mutating func getCountries(completion: @escaping (Result<[CountryModel], Error>) -> Void){
        if let url = constants.allCountriesURL {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    return
                }
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode([CountryModel].self, from: safeData)
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
        case .defaultCountry(let country): stringURL = "\(constants.baseURLString)\(country.slug)"
        case .country(let country): stringURL = "\(constants.baseURLString)\(country.slug)"
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

struct CountryModel: Codable {
    let country: String
    let slug: String
    
    private enum CodingKeys: String, CodingKey {
        case country = "Country"
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
