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

class MainVC: UIViewController {
    @IBOutlet weak var labelNameCity: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var search = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()
    private let vm = MainModelView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        
        search.searchBar.rx.searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { _ in
                if let city = self.search.searchBar.text{
                    self.vm.getWeatherCity(city)
                }
            }).disposed(by: disposeBag)
        
        vm.modelWeather?.map{ $0.name }.bind(to: labelNameCity.rx.text).disposed(by: disposeBag)
        vm.modelWeather?.map{ String($0.temp) }.bind(to: labelTemperature.rx.text).disposed(by: disposeBag)
        
        _ = vm.error?.subscribe{ error in
            if let text = error.element?.localizedDescription{
                let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func setupNavigationBar() {
        self.navigationItem.searchController = search
    }
}
