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
        static let worldURL = "https://api.covid19api.com/world"
    }
    
    enum DataScope {
        case world
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
        case .world: stringURL = Constants.worldURL
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
    let Active: Int
    let Date: String
}

//struct CovidData {
//    let Cases: Int
//    let Date: Date
//}

struct NationalData: Codable {
    let NewConfirmed: Int
    let TotalConfirmed: Int
    let NewDeaths: Int
    let TotalDeaths: Int
    let NewRecovered: Int
    let TotalRecovered: Int
    let Date: String
}
