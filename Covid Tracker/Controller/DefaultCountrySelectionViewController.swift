//
//  SettingsViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/16.
//

import UIKit

class DefaultCountrySelectionViewController: UIViewController {
    private lazy var apiCaller = ApiCaller()
    private lazy var defaults = UserDefaults()
    
    private var countries: [CountryModel] = [] {
        didSet {
            setupDictionary()
        }
    }
    
    private var sections = [Section]()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select Default Country"
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        getCountries()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func getCountries(){
        apiCaller.getCountries { [weak self] result in
            switch result {
            case .success(let countries):
                self?.countries = countries.sorted(by: { $0.Country < $1.Country })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupDictionary() {
        let groupedDictionary = Dictionary(grouping: countries, by: {String($0.Country.prefix(1))})
        let keys = groupedDictionary.keys.sorted()
        sections = keys.map{ Section(letter: $0, countryNames: groupedDictionary[$0]!) }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension DefaultCountrySelectionViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].countryNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let section = sections[indexPath.section]
        let countryName = section.countryNames[indexPath.row]
        cell.textLabel?.text = countryName.Country
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        let selectedCountry = section.countryNames[indexPath.row]
        defaults.set(selectedCountry.Country, forKey: "DefaultCountryName")
        defaults.set(selectedCountry.Slug, forKey: "DefaultCountrySlug")
        
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map{$0.letter}
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].letter.uppercased()
    }
}
