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
    private lazy var constants = Constants()
    
    private var scope: ApiCaller.DataScope = .defaultCountry(CountryModel(country: "South Africa", slug: "south-africa"))
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
        
        if let defaultName = UserDefaults().string(forKey: constants.defaultCountryNameKey), let defaultSlug = UserDefaults().string(forKey: constants.defaultCountrySlugKey) {
            scope = .defaultCountry(CountryModel(country: defaultName, slug: defaultSlug))
        }
        
        filterButton.tintColor = .darkGray
        settingsButton.tintColor = .darkGray
        updateFilterButton()
        getData()
        formatGraph()
    }
    
    //MARK: - Filter Button
    func updateFilterButton() {
        filterButton.title = selectedCountryText
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
        var graphDataInstance: Int = 0
        set = data.suffix(31)
        
        for index in 0..<set.endIndex {
            switch selectedStatus {
            case .active:
                graphDataInstance = set[index].active
            case .confirmed:
                graphDataInstance = set[index].confirmed
            case .deaths:
                graphDataInstance = set[index].deaths
            case .recovered:
                graphDataInstance = set[index].recovered
            }
            entries.append(BarChartDataEntry(x: Double(index), y: Double(graphDataInstance)))
            dates.append(set[index].date.replacingOccurrences(of: "T00:00:00Z", with: ""))
        }
        
        let dataSet = BarChartDataSet(entries: entries)
        formatDataSet(dataSet)
        formatXAxis(with: dates)
        let chartData: BarChartData = BarChartData(dataSet: dataSet)
        
        chartView.data = chartData
    }
    
    private func formatGraph() {
        chartView.zoom(scaleX: 5, scaleY: 1, x: 0, y: 0)
        chartView.noDataText = "No Cases for: \(selectedCountryText)"
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.extraBottomOffset = 30
    }
    
    private func formatDataSet(_ dataSet: BarChartDataSet) {
        dataSet.colors = ChartColorTemplates.material()
        switch selectedStatus {
        case .active:
            dataSet.label = "Active cases for: \(selectedCountryText)"
        case .confirmed:
            dataSet.label = "Confirmed cases for: \(selectedCountryText)"
        case .deaths:
            dataSet.label = "Deaths for: \(selectedCountryText)"
        case .recovered:
            dataSet.label = "Recoveries for: \(selectedCountryText)"
        }
    }
    
    private func formatXAxis(with dates: [String]) {
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
        chartView.xAxis.labelRotationAngle = 30
    }
    
    //MARK: - @objc & @IBAction
    @objc private func tappedSettingButton(){
        let settingsVC = DefaultCountrySelectionTableViewController()
        let navVC = UINavigationController(rootViewController: settingsVC)
        present(navVC, animated: true)
    }
    
    @objc private func tappedFilterButton(){
        let filterVC = FilterTableViewController()
        filterVC.completion = { [weak self] country in
            self?.scope = .country(country)
            self?.getData()
            self?.updateFilterButton()
        }
        let navVC = UINavigationController(rootViewController: filterVC)
        present(navVC, animated: true)
    }
    
    @IBAction func radioButtonsTapped(_ sender: UIButton) {
        deselectAllButtons()
        switch sender.titleLabel?.text {
        case "Active":
            selectedStatus = .active
            activeButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        case "Confirmed":
            selectedStatus = .confirmed
            confirmedButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        case "Deaths":
            selectedStatus = .deaths
            deathsButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        case "Recovered":
            selectedStatus = .recovered
            recoveredButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        default:
            selectedStatus = .active
        }
        
        self.reloadGraphData()
    }
    
    private func deselectAllButtons() {
        activeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
    }
    
    private var selectedCountryText: String {
        switch scope {
        case .defaultCountry(let country): return country.country
        case .country(let country): return country.country
        }
    }
}
