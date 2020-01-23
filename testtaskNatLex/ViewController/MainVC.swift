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

protocol ClickDetals {
    func clickDetals(name: String)
}


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
                cell.delegate = self
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
            return self.isF ? String($0.temp) + "˚F" : String($0.temp) + "˚C"
        }.bind(to: labelTemperature.rx.text).disposed(by: disposeBag)
        
        _ = vm.modelWeather?.subscribe{ event in
            if let element = event.element{
                let first = self.isF ? Double(10).conventToFarengate() : 10
                let second = self.isF ? Double(25).conventToFarengate() : 25
                let last = self.isF ? Double(10000).conventToFarengate() : 10000
                
                print("first \(first) \(second) \(element.temp)")
                
                switch element.temp {
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
        clickRequestPermission()
    }
    
    @IBAction func switchMetric(_ sender: UISwitch) {
        isF = !sender.isOn
        //tableView.reloadData()
        vm.updateInfo(isFarengate: isF)
    }
    
    func clickRequestPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .denied:
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
                break
            case .notDetermined, .restricted:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                break
            @unknown default:
                break;
            }
            
        } else {
            print("Location services are not enabled")
        }
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

extension MainVC: ClickDetals{
    func clickDetals(name: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChartVC") as? ChartVC{
            vc.nameCity = name
            vc.isFarengate = isF
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
