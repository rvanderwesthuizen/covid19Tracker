//
//  ViewController.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/07/08.
//

import UIKit
import Charts
import CoreLocation

class CovidDataViewController: UIViewController {
    private let covidDataViewModel = CovidDataViewModel()
    private let locationManager = CLLocationManager()
    
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
    @IBOutlet private weak var chartView: BarChartView!
    @IBOutlet private weak var segmentedController: UISegmentedControl!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Covid Tracker"
        navigationItem.rightBarButtonItem = filterButton
        navigationItem.leftBarButtonItem = settingsButton
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if locationManager.authorizationStatus == .denied {
            covidDataViewModel.checkForDefault()
            getData()
        }
        
        activateActivityIndicator()
        
        filterButton.tintColor = .darkGray
        settingsButton.tintColor = .darkGray
        self.formatGraph()
    }
    
    //MARK: - Filter Button
    func updateFilterButton() {
        filterButton.title = covidDataViewModel.selectedCountryText
    }
    
    //MARK: - Activity Indicator
    func activateActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    //MARK: - Get covid data
    private func getData() {
        covidDataViewModel.getData {
            DispatchQueue.main.async {
                self.reloadGraphData()
                self.activityIndicator.stopAnimating()
                self.updateFilterButton()
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
        
        if entries.count == 0 {
            showAlertForNoCases()
            
            segmentedController.isEnabled = false
        } else {
            segmentedController.isEnabled = true
        }
        let dataSet = BarChartDataSet(entries: entries)
        formatDataSet(dataSet)
        formatXAxis()
        let chartData: BarChartData = BarChartData(dataSet: dataSet)
        
        chartView.data = chartData
        
    }
    
    private func showAlertForNoCases() {
        let alertController = UIAlertController(title: "", message: "\(covidDataViewModel.selectedCountryText) has no cases", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true)
    }
    
    private func showAlertWhenLocationNotFound() {
        let alertController = UIAlertController(title: "", message: "We could not find your current country, will display the default country selected", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true)
    }
    
    private func formatGraph() {
        chartView.doubleTapToZoomEnabled = false
        chartView.zoom(scaleX: 5, scaleY: 1, x: 0, y: 0)
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
            self?.activateActivityIndicator()
            self?.getData()
            self?.updateFilterButton()
        }
        let navVC = UINavigationController(rootViewController: filterVC)
        present(navVC, animated: true)
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            covidDataViewModel.selectedStatus = .active
        case 1:
            covidDataViewModel.selectedStatus = .confirmed
        case 2:
            covidDataViewModel.selectedStatus = .deaths
        case 3:
            covidDataViewModel.selectedStatus = .recovered
        default:
            covidDataViewModel.selectedStatus = .active
        }
        
        self.reloadGraphData()
    }
}

extension CovidDataViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .denied && status != .notDetermined {
            locationManager.requestLocation()
        } else {
            covidDataViewModel.checkForDefault()
            getData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        covidDataViewModel.geoLocation(from: location) {
            if !self.covidDataViewModel.found {
                self.showAlertWhenLocationNotFound()
            }
            self.getData()
        }
    }
}
