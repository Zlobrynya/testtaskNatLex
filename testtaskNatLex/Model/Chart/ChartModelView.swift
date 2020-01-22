//
//  ChartModelView.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 22/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation
import RxSwift

class ChartModelView {    
    var modelsWeatherSubject: ReplaySubject<[ModelWeather]>? = ReplaySubject.create(bufferSize: 2)
    
    var modelsWeather = [ModelWeather]()
    
    init() {

    }
    
    func getData(city nameCity: String){
        let observ = AcessCodeData.sharedInstance.getWeatherHistory(city: nameCity)
        observ.subscribe({ event in
            if let element = event.element{
                self.modelsWeatherSubject?.onNext(element)
                self.modelsWeather = element
            }
        })
    }
    
    
}
