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
                self.createGraph()
            }
        }
    }
    
    private var scope: ApiCaller.DataScope = .defaultCountry(CountryModel(Country: "South Africa", Slug: "south-africa"))
    
    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Filter",
            style: .done,
            target: self,
            action: #selector(filterButtonPressed))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Covid Cases"
        createFilterButton()
        getData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func createFilterButton() {
        filterButton.title = getSelectedCountryText()
        navigationItem.rightBarButtonItem = filterButton
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
    
    public func createGraph() {
        
        var entries: [BarChartDataEntry] = []
        var dates: [String] = []
        
        let set = data.suffix(31)
        for index in set.startIndex..<set.endIndex {
            let data = set[index]
            entries.append(BarChartDataEntry(x: Double(index), y: Double(data.Active)))
            dates.append(data.Date.replacingOccurrences(of: "T00:00:00Z", with: ""))
        }
        let dataSet = BarChartDataSet(entries: entries)
        formatDataSet(dataSet)
        let chartData: BarChartData = BarChartData(dataSet: dataSet)
        
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height))
        chart.noDataText = "No Cases for: \(getSelectedCountryText())"
        chart.data = chartData
        formatXAxis(chart.xAxis, with: dates)
        chart.rightAxis.enabled = false
        chart.leftAxis.axisMinimum = 0
        
        configureViews(chart: chart)
    }
    
    private func configureViews(chart : BarChartView) {
        view.addSubview(chart)
        
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: view.topAnchor),
            chart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func formatDataSet(_ dataSet: BarChartDataSet) {
        dataSet.colors = ChartColorTemplates.material()
        dataSet.label = "Active cases for: \(getSelectedCountryText())"
    }
    
    private func formatXAxis(_ xAxis: XAxis, with dates: [String]) {
        xAxis.setLabelCount(dates.count, force: false)
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
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
    
    private func getSelectedCountryText() -> String {
        switch scope {
        case .defaultCountry(let country): return country.Country
        case .country(let country): return country.Country
        }
    }
}
