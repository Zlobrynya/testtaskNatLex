//
//  MainModelView.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 21/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation

class MainModelView {
    var modelsWeather = [ModelWeather]()
    var modelWeatherOnMain = ModelWeather()
    
    func getWeatherCity(_ city: String, completionHandler: @escaping (Error?) -> ()){
        ServerModel().getWeatherAtCity(city){ modelCity, error in
            if let error = error{
                completionHandler(error)
                return
            }
            if let modelCity = modelCity{
                self.subscribeObservable(modelCity)
            }
            completionHandler(nil)
        }
    }
    
    func getWeatherByCoord(lat: String, lon: String, completionHandler: @escaping (Error?) -> ()){
        
        ServerModel().getWeatherByCoord(lat: lat, lon: lon){ modelCity, error in
            if let modelCity = modelCity{
                self.subscribeObservable(modelCity)
            }
            completionHandler(error)
        }
    }
    
    func getLastData(completionHandler: @escaping (Bool?) -> ()){
        let weathers = AcessCodeData.sharedInstance.getLastCoreData()
        modelsWeather += weathers
        print("modelsWeather \(modelsWeather.count)")
        completionHandler(true)
    }
    
    func updateInfo(isFarengate: Bool, completionHandler: @escaping (Bool?) -> ()){
        for item in modelsWeather{
            item.changeMetric(isFarengate: isFarengate)
        }
        completionHandler(true)
    }
    
    private func subscribeObservable(_ modelCity: ModelWeather){
        self.modelWeatherOnMain = modelCity
        AcessCodeData.sharedInstance.addPostToCoreData(model: modelCity)
        // Замена и обновление таблицы
        if let item = self.modelsWeather.firstIndex(where: { $0.name == modelCity.name }){
            let locEl = modelCity
            locEl.countUnique = self.modelsWeather[item].countUnique + 1
            self.modelsWeather[item] = locEl
        }else{
            self.modelsWeather.append(modelCity)
        }
    }
}
