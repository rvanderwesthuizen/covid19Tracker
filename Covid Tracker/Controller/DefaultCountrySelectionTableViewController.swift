//
//  SettingsViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/16.
//

import UIKit

class DefaultCountrySelectionTableViewController: UITableViewController {
    private lazy var defaults = UserDefaults()
    private lazy var constants = Constants()
    private let countryViewModel = CountryViewModel()
    
    private var countries: [Section] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Default Country"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        getCountries()
    }
    
    private func getCountries(){
        countryViewModel.getCountries { sections in
            self.countries = sections
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries[section].countryNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let section = countries[indexPath.section]
        let countryName = section.countryNames[indexPath.row]
        cell.textLabel?.text = countryName.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = countries[indexPath.section]
        let selectedCountry = section.countryNames[indexPath.row]
        defaults.set(selectedCountry.name, forKey: constants.defaultCountryNameKey)
        defaults.set(selectedCountry.slug, forKey: constants.defaultCountrySlugKey)
        
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return countries.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return countries.map{$0.letter}
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return countries[section].letter.uppercased()
    }
}
