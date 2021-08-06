//
//  SettingsViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/16.
//

import UIKit

class DefaultCountrySelectionTableViewController: UITableViewController {
    private let countryViewModel = DefaultCountryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Default Country".localized()
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
        
        countryViewModel.setDefaults(selectedCountry)
        showAlert()
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "", message: "Default country has been set".localized(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)}))
        
        present(alertController, animated: true)
        
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
