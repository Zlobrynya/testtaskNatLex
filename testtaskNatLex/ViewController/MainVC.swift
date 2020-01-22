//
//  ViewController.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 21/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CoreLocation

class MainVC: UIViewController {
    @IBOutlet weak var labelNameCity: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainViewInfo: UIView!
    
    private var search = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()
    private let vm = MainModelView()
    private let locationManager = CLLocationManager()
    private var isF = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        initLocation()
        bindMainInfo()
        bindTable()
    }
    
    private func bindTable(){
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        vm.lastModelsWeather?.bind(to: tableView.rx.items(cellIdentifier: "infoCell")){ row, model, cell in
            if let cell = cell as? InfoTableViewCell{
                cell.setData(model: model, isF: self.isF)
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindMainInfo(){
        search.searchBar.rx.searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { _ in
                if let city = self.search.searchBar.text{
                    self.vm.getWeatherCity(city)
                }
            }).disposed(by: disposeBag)
        
        vm.modelWeather?.map{ $0.name }.bind(to: labelNameCity.rx.text).disposed(by: disposeBag)
        vm.modelWeather?.map{
            var temp = $0.temp
            if self.isF{
                temp *= 32
                return String(temp) + "˚F"
            }else{
                return String(temp) + "˚C"
            }
        }.bind(to: labelTemperature.rx.text).disposed(by: disposeBag)
        
        _ = vm.modelWeather?.subscribe{ event in
            if let element = event.element{
                switch element.temp {
                case -100..<10:
                    self.mainViewInfo.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                    break
                case 10...25:
                    self.mainViewInfo.backgroundColor = #colorLiteral(red: 1, green: 0.6470588235, blue: 0, alpha: 1)
                    break
                case 100..<25:
                    self.mainViewInfo.backgroundColor = #colorLiteral(red: 1, green: 0.02745098062, blue: 0, alpha: 1)
                    break
                default:
                    self.mainViewInfo.backgroundColor = #colorLiteral(red: 0.4851023555, green: 0.2691538334, blue: 0.9763388038, alpha: 1)
                    break
                }
            }
        }
        
        _ = vm.error?.subscribe{ error in
            if let text = error.element?.localizedDescription{
                let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func setupNavigationBar() {
        self.navigationItem.searchController = search
    }
    
    private func initLocation(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()


        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
            //locationManager.requestLocation()
        }
    }
    
    @IBAction func clickLoc(_ sender: Any) {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func switchMetric(_ sender: UISwitch) {
        isF = !sender.isOn
        tableView.reloadData()
        vm.updateInfo()
    }
}


extension MainVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.vm.getWeatherByCoord(lat: String(locValue.latitude), lon: String(locValue.longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

extension MainVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
