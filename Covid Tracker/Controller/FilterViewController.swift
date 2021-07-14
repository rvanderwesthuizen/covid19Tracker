//
//  FilterViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import UIKit

class FilterViewController: UIViewController {

    public var completion: ((CountryModel) -> Void)?
    private var apiCaller = ApiCaller()
    
    private var countries: [CountryModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select Country"
        
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
}

extension FilterViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let country = countries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = country.Country
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCountry = countries[indexPath.row]
        completion?(selectedCountry)
        
        dismiss(animated: true, completion: nil)
    }
}
