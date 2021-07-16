//
//  ViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import UIKit
import Charts

class ViewController: UIViewController {
    enum statusSelector {
        case active
        case confirmed
        case deaths
        case recovered
    }
    
    private lazy var apiCaller = ApiCaller()
    
    private var scope: ApiCaller.DataScope = .defaultCountry(CountryModel(Country: UserDefaults().string(forKey: "DefaultCountryName")!, Slug: UserDefaults().string(forKey: "DefaultCountrySlug")!))
    private var selectedStatus: statusSelector = .active
    
    private lazy var data: [CovidDataResult] = [] {
        didSet{
            DispatchQueue.main.async {
                self.reloadGraphData()
            }
        }
    }
    
    private lazy var set: [CovidDataResult] = []
    
    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Filter",
            style: .done,
            target: self,
            action: #selector(tappedFilterButton))
        return button
    }()
    
    private lazy var settingsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Set default",
            style: .plain,
            target: self,
            action: #selector(tappedSettingButton))
        return button
    }()
    
    //MARK: - @IBOutlets
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var confirmedButton: UIButton!
    @IBOutlet weak var deathsButton: UIButton!
    @IBOutlet weak var recoveredButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Covid Tracker"
        navigationItem.rightBarButtonItem = filterButton
        navigationItem.leftBarButtonItem = settingsButton
        
        filterButton.tintColor = .darkGray
        settingsButton.tintColor = .darkGray
        updateFilterButton()
        getData()
        formatGraph()
    }
    
    //MARK: - Filter Button
    func updateFilterButton() {
        filterButton.title = getSelectedCountryText()
    }
    
    //MARK: - Get covid data
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
    
    //MARK: - Graph
    public func reloadGraphData() {
        var entries: [BarChartDataEntry] = []
        var dates: [String] = []
        set = data.suffix(31)
        switch selectedStatus {
        case .active:
            for index in 0..<set.endIndex {
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
        formatXAxis(with: dates)
        let chartData: BarChartData = BarChartData(dataSet: dataSet)
        
        chartView.data = chartData
    }
    
    private func formatGraph() {
        chartView.zoom(scaleX: 5, scaleY: 1, x: 0, y: 0)
        chartView.noDataText = "No Cases for: \(getSelectedCountryText())"
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.extraBottomOffset = 30
    }
    
    private func formatDataSet(_ dataSet: BarChartDataSet) {
        dataSet.colors = ChartColorTemplates.material()
        switch selectedStatus {
        case .active:
            dataSet.label = "Active cases for: \(getSelectedCountryText())"
        case .confirmed:
            dataSet.label = "Confirmed cases for: \(getSelectedCountryText())"
        case .deaths:
            dataSet.label = "Deaths for: \(getSelectedCountryText())"
        case .recovered:
            dataSet.label = "Recoveries for: \(getSelectedCountryText())"
        }
    }
    
    private func formatXAxis(with dates: [String]) {
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
        chartView.xAxis.labelRotationAngle = 30
    }
    
    //MARK: - @objc & @IBAction
    @objc private func tappedSettingButton(){
        let settingsVC = DefaultCountrySelectionViewController()
        let navVC = UINavigationController(rootViewController: settingsVC)
        present(navVC, animated: true)
    }
    
    @objc private func tappedFilterButton(){
        let filterVC = FilterViewController()
        filterVC.completion = { [weak self] country in
            self?.scope = .country(country)
            self?.getData()
            self?.updateFilterButton()
        }
        let navVC = UINavigationController(rootViewController: filterVC)
        present(navVC, animated: true)
    }

    @IBAction func radioButtonsTapped(_ sender: UIButton) {
        switch sender.titleLabel?.text {
        case "Active":
            selectedStatus = .active
            activeButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        case "Confirmed":
            selectedStatus = .confirmed
            activeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        case "Deaths":
            selectedStatus = .deaths
            activeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        case "Recovered":
            selectedStatus = .recovered
            activeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        default:
            selectedStatus = .active
            activeButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        }
        DispatchQueue.main.async {
            self.reloadGraphData()
        }
    }
    
    //MARK: - Other functions
    private func getSelectedCountryText() -> String {
        switch scope {
        case .defaultCountry(let country): return country.Country
        case .country(let country): return country.Country
        }
    }
}
