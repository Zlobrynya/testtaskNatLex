//
//  MainModelView.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 21/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation
import RxSwift

class MainModelView {
    var modelWeather: PublishSubject<ModelWeather>? = PublishSubject()
    var error: PublishSubject<Error>? = PublishSubject()
    
    init() {}
    
    func getWeatherCity(_ city: String){
        let obs = ServerModel().getWeatherAtCity(city)
        _ = obs?.subscribe{ event in
            print("event \(event)")
            if let error = event.error{
                self.error?.onNext(error)
            }
            
            if let element = event.element{
                self.modelWeather?.onNext(element)
            }
        }
    }
}
