//
//  ViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import UIKit
import Charts

class ViewController: UIViewController {
    private var apiCaller = ApiCaller()
    
    private var data: [CovidDataResult] = [] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.createGraph()
            }
        }
    }
    
    private var scope: ApiCaller.DataScope = .world
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return table
    }()
    
    private func createGraph() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        headerView.clipsToBounds = true
        
        var entries: [BarChartDataEntry] = []
        let set = data.suffix(100)
        for index in set.startIndex..<set.endIndex {
            let data = set[index]
            entries.append(BarChartDataEntry(x: Double(index), y: Double(data.Active)))
        }
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = ChartColorTemplates.joyful()
        let chartData: BarChartData = BarChartData(dataSet: dataSet)
        
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        chart.data = chartData
        
        headerView.addSubview(chart)
        
        tableView.tableHeaderView = headerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Active Covid Cases"
        createFilterButton()
        configureTable()
        //        getData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
    }
    
    func createFilterButton() {
        let buttonTitle: String = { () -> String in
            switch scope {
            case .world: return "World Wide"
            case .country(let country): return country.Country
            }
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: buttonTitle,
            style: .done,
            target: self,
            action: #selector(filterButtonPressed))
    }
    
    @objc private func filterButtonPressed(){
        let filterVC = FilterViewController()
        filterVC.completion = { [weak self] country in
            self?.scope = .country(country)
            self?.getData()
            self?.createFilterButton()
        }
        let navVC = UINavigationController(rootViewController: filterVC)
        present(navVC, animated: true)
    }
    
    private func getData() {
        apiCaller.getCovidData(for: scope) { [weak self] result in
            switch result {
            case .success(let data):
                self?.data = data
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = data[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = createText(with: data)
        
        return cell
    }
    
    private func createText(with data: CovidDataResult) -> String {
        let date = data.Date.replacingOccurrences(of: "T00:00:00Z", with: "")
        let total = data.Active
        return "\(date): \(total)"
    }
}
