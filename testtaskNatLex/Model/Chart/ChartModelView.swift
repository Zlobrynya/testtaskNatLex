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
    
    func getData(city nameCity: String, isFarengate: Bool){
        let observ = AcessCodeData.sharedInstance.getWeatherHistory(city: nameCity)
        _ = observ.subscribe({ event in
            if let element = event.element{
                if isFarengate{
                    for item in element{
                        item.changeMetric(isFarengate: isFarengate)
                    }
                }

                self.modelsWeatherSubject?.onNext(element)
                self.modelsWeather = element
            }
        })
    }
    
    
}
