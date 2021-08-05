//
//  FilterViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import UIKit

class FilterTableViewController: UITableViewController {
    public var completion: ((Country) -> Void)?
    private let countryViewModel = CountryViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select Country"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        getCountries()
    }
    
    private func getCountries(){
        countryViewModel.getCountries {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryViewModel.numberOfRowsInSection(at: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let section = countryViewModel.country(at: indexPath.section) else { return cell }
        let countryName = section.countryNames[indexPath.row]
        cell.textLabel?.text = countryName.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = countryViewModel.country(at: indexPath.section) else { return }
        let selectedCountry = section.countryNames[indexPath.row]
        completion?(selectedCountry)
        
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return countryViewModel.counts
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return countryViewModel.letters
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return countryViewModel.letter(at: section)?.uppercased()
    }
    
}
