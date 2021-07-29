//
//  FilterViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import UIKit

class FilterTableViewController: UITableViewController {
    public var completion: ((CountryModel) -> Void)?
    
    public var countries: [CountryViewModel.Section] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select Country"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        getCountries()
    }
    
    private func getCountries(){
        CountryViewModel().getCountries { sections in
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
        completion?(selectedCountry)
        
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
