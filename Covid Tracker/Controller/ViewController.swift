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
            reloadGraphData()
        }
    }
    
    enum resultSelector {
        case active
        case confirmed
        case deaths
        case recovered
    }
    
    private var scope: ApiCaller.DataScope = .defaultCountry(CountryModel(Country: "South Africa", Slug: "south-africa"))
    private var selectedResult: resultSelector = .active
    
    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Filter",
            style: .done,
            target: self,
            action: #selector(filterButtonPressed))
        return button
    }()
    
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var confirmedButton: UIButton!
    @IBOutlet weak var deathsButton: UIButton!
    @IBOutlet weak var recoveredButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Covid Cases"
        createFilterButton()
        getData()
        
        chartView.zoom(scaleX: 10, scaleY: 10, x: 0, y: 0)
        chartView.noDataText = "No Cases for: \(getSelectedCountryText())"
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func createFilterButton() {
        filterButton.tintColor = .systemTeal
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
    
    public func reloadGraphData() {
        var entries: [BarChartDataEntry] = []
        var dates: [String] = []
        
        let set = data.suffix(31)
        
        switch selectedResult {
        case .active:
            for index in set.startIndex..<set.endIndex {
                let data = set[index]
                entries.append(BarChartDataEntry(x: Double(index), y: Double(data.Active)))
                dates.append(data.Date.replacingOccurrences(of: "T00:00:00Z", with: ""))
            }
        case .confirmed:
            for index in set.startIndex..<set.endIndex {
                let data = set[index]
                entries.append(BarChartDataEntry(x: Double(index), y: Double(data.Confirmed)))
                dates.append(data.Date.replacingOccurrences(of: "T00:00:00Z", with: ""))
            }
        case .deaths:
            for index in set.startIndex..<set.endIndex {
                let data = set[index]
                entries.append(BarChartDataEntry(x: Double(index), y: Double(data.Deaths)))
                dates.append(data.Date.replacingOccurrences(of: "T00:00:00Z", with: ""))
            }
        case .recovered:
            for index in set.startIndex..<set.endIndex {
                let data = set[index]
                entries.append(BarChartDataEntry(x: Double(index), y: Double(data.Recovered)))
                dates.append(data.Date.replacingOccurrences(of: "T00:00:00Z", with: ""))
            }
        }
        
        let dataSet = BarChartDataSet(entries: entries)
        formatDataSet(dataSet)
        let chartData: BarChartData = BarChartData(dataSet: dataSet)
        
        chartView.data = chartData
        formatXAxis(chartView.xAxis, with: dates)
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

    @IBAction func radioButtonsTapped(_ sender: UIButton) {
        switch selectedResult {
        case .active:
            selectedResult = .active
            activeButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        case .confirmed:
            selectedResult = .confirmed
            activeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        case .deaths:
            selectedResult = .deaths
            activeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        case .recovered:
            selectedResult = .recovered
            activeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        }
        
        reloadGraphData()
    }
    
    private func getSelectedCountryText() -> String {
        switch scope {
        case .defaultCountry(let country): return country.Country
        case .country(let country): return country.Country
        }
    }
}
