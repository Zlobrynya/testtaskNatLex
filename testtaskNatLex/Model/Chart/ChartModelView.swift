//
//  ChartModelView.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 22/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation

class ChartModelView {
    var modelsWeather = [ModelWeather]()
    
    func getData(city nameCity: String, isFarengate: Bool, completionHandler: @escaping (Error?) -> ()){
        AcessCodeData.sharedInstance.getWeatherHistory(city: nameCity) { models, error in
            if let models = models{
                if isFarengate{
                    for item in models{
                        item.changeMetric(isFarengate: isFarengate)
                    }
                }
                self.modelsWeather = models
            }
            completionHandler(error)
        }
    }
}
