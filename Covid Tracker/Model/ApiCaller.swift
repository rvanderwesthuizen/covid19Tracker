//
//  ApiCaller.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import Foundation

struct ApiCaller {
    
    private struct Constants {
        static let allCountriesURL = URL(string: "https://api.covid19api.com/countries")
        static let baseURLString = "https://api.covid19api.com/country/"
    }
    
    enum DataScope {
        case defaultCountry(CountryModel)
        case country(CountryModel)
    }
    
    public func getCountries(completion: @escaping (Result<[CountryModel], Error>) -> Void){
        if let url = Constants.allCountriesURL {
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
    
    public func getCovidData(for scope: DataScope, completion: @escaping (Result<[CovidDataResult], Error>) -> Void){
        let stringURL: String
        switch scope {
        case .defaultCountry(let country): stringURL = "\(Constants.baseURLString)\(country.Slug)"
        case .country(let country): stringURL = "\(Constants.baseURLString)\(country.Slug)"
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
    let Country: String
    let Slug: String
}

struct CovidDataResult: Codable {
    let Confirmed: Int
    let Deaths: Int
    let Recovered: Int
    let Active: Int
    let Date: String
}
