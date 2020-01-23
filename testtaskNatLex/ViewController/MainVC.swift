//
//  ViewController.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 21/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit
import CoreLocation

protocol ClickDetals {
    func clickDetals(name: String)
}


class MainVC: UIViewController {
    @IBOutlet weak var labelNameCity: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainViewInfo: UIView!
    
    private var search = UISearchController(searchResultsController: nil)
    private let vm = MainModelView()
    private let locationManager = CLLocationManager()
    private var isF = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        initLocation()
        tableView.delegate = self
        tableView.dataSource = self
        vm.getLastData(){ _ in
            self.tableView.reloadData()
        }
    }
    
    private func setupNavigationBar() {
        self.navigationItem.searchController = search
        search.searchBar.delegate = self
    }
    
    private func initLocation(){
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateUI(){
        labelNameCity.text = vm.modelWeatherOnMain.name
        labelTemperature.text = self.isF ? String(vm.modelWeatherOnMain.temp) + "˚F" : String(vm.modelWeatherOnMain.temp) + "˚C"
        updateMainUI()
        tableView.reloadData()
    }
    
    func showError(error: Error){
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func updateMainUI(){
        let first = self.isF ? Double(10).conventToFarengate() : 10
        let second = self.isF ? Double(25).conventToFarengate() : 25
        let last = self.isF ? Double(10000).conventToFarengate() : 10000
                
        switch vm.modelWeatherOnMain.temp {
        case ..<first:
            self.mainViewInfo.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            break
        case first...second:
            self.mainViewInfo.backgroundColor = #colorLiteral(red: 1, green: 0.6470588235, blue: 0, alpha: 1)
            break
        case second..<last:
            self.mainViewInfo.backgroundColor = #colorLiteral(red: 1, green: 0.02745098062, blue: 0, alpha: 1)
            break
        default:
            self.mainViewInfo.backgroundColor = #colorLiteral(red: 0.4851023555, green: 0.2691538334, blue: 0.9763388038, alpha: 1)
            break
        }
    }
    
    @IBAction func clickLoc(_ sender: Any) {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func switchMetric(_ sender: UISwitch) {
        isF = !sender.isOn
        //tableView.reloadData()
        vm.updateInfo(isFarengate: isF){ _ in
            self.updateUI()
        }
    }
}


extension MainVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.vm.getWeatherByCoord(lat: String(locValue.latitude), lon: String(locValue.longitude)){ error in
            if let error = error {
                self.showError(error: error)
                return
            }
            self.updateUI()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableView(_ tableView: UITableView, \(vm.modelsWeather.count)")
        return vm.modelsWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as? InfoTableViewCell{
            print("tableView(_ cellForRowAt: UITableView, \(vm.modelsWeather[indexPath.row].name)")
            if indexPath.row < vm.modelsWeather.count {
                cell.delegate = self
                cell.setData(model: vm.modelsWeather[indexPath.row], isF: self.isF)
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension MainVC: ClickDetals{
    func clickDetals(name: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChartVC") as? ChartVC{
            vc.nameCity = name
            vc.isFarengate = isF
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MainVC: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        if let city = self.search.searchBar.text{
            self.vm.getWeatherCity(city){ error in
                if let error = error{
                    self.showError(error: error)
                }else{
                    if !self.vm.modelWeatherOnMain.name.isEmpty{
                        self.updateUI()
                    }
                }
            }
        }
    }
}
