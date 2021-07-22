//
//  FilterViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import UIKit

class FilterTableViewController: UITableViewController {

    
    public var completion: ((CountryModel) -> Void)?
    private let countryViewModel = CountryViewModel()
    
    public var countries: [CountryModel] = [] {
        didSet {
            setupDictionary()
        }
    }
    
    private var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select Country"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        getCountries()
    }
    
    private func getCountries(){
        countryViewModel.getCountries()
        countries = countryViewModel.countryList
    }
    
    private func setupDictionary() {
        let groupedDictionary = Dictionary(grouping: countries, by: {String($0.country.prefix(1))})
        let keys = groupedDictionary.keys.sorted()
        sections = keys.map{ Section(letter: $0, countryNames: groupedDictionary[$0]!) }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].countryNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let section = sections[indexPath.section]
        let countryName = section.countryNames[indexPath.row]
        cell.textLabel?.text = countryName.country
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        let selectedCountry = section.countryNames[indexPath.row]
        completion?(selectedCountry)
        
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map{$0.letter}
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].letter.uppercased()
    }
    
    private struct Section {
        let letter: String
        let countryNames: [CountryModel]
    }
}