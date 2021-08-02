//
//  ViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import UIKit
import Charts

class ViewController: UIViewController {
    private let covidDataViewModel = CovidDataViewModel()
    
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
        
        covidDataViewModel.checkForDefault()
        
        filterButton.tintColor = .darkGray
        settingsButton.tintColor = .darkGray
        updateFilterButton()
        getData()
        formatGraph()
    }
    
    //MARK: - Filter Button
    func updateFilterButton() {
        filterButton.title = covidDataViewModel.selectedCountryText
    }
    
    //MARK: - Get covid data
    private func getData() {
        covidDataViewModel.getData {
            DispatchQueue.main.async {
                self.reloadGraphData()
            }
        }
    }
    
    //MARK: - Graph
    public func reloadGraphData() {
        var entries: [BarChartDataEntry] = []
        
        for index in 0..<covidDataViewModel.set.endIndex {
            covidDataViewModel.setupDates(at: index)
            entries.append(BarChartDataEntry(x: Double(index), y: Double(covidDataViewModel.graphDataInstance(at: index))))
        }
        
        let dataSet = BarChartDataSet(entries: entries)
        formatDataSet(dataSet)
        formatXAxis()
        let chartData: BarChartData = BarChartData(dataSet: dataSet)
        
        chartView.data = chartData
    }
    
    private func formatGraph() {
        chartView.doubleTapToZoomEnabled = false
        chartView.zoom(scaleX: 5, scaleY: 1, x: 0, y: 0)
        chartView.noDataText = "No Cases for: \(covidDataViewModel.selectedCountryText)"
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.extraBottomOffset = 30
    }
    
    private func formatDataSet(_ dataSet: BarChartDataSet) {
        dataSet.colors = ChartColorTemplates.material()
        dataSet.label = covidDataViewModel.dataSetLabel()
    }
    
    private func formatXAxis() {
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: covidDataViewModel.dates)
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
            self?.covidDataViewModel.scope = .country(country)
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
            covidDataViewModel.selectedStatus = .active
            activeButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        case "Confirmed":
            covidDataViewModel.selectedStatus = .confirmed
            confirmedButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        case "Deaths":
            covidDataViewModel.selectedStatus = .deaths
            deathsButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        case "Recovered":
            covidDataViewModel.selectedStatus = .recovered
            recoveredButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        default:
            covidDataViewModel.selectedStatus = .active
        }
        
        self.reloadGraphData()
    }
    
    private func deselectAllButtons() {
        activeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        confirmedButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        deathsButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        recoveredButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
    }
}
