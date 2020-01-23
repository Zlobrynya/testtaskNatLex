//
//  ServerModel.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 21/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ServerModel {
    private var apiKey = "7c64957ea897785f6db59d4c648c5d66"
    private var url = "https://api.openweathermap.org/data/2.5/weather?"
    
    func getWeatherAtCity(_ city: String, completionHandler: @escaping (ModelWeather?, Error?) -> ()){
        let parameters:[String:String] = ["q":city,
                                          "units": "metric",
                                          "appid":self.apiKey]//units=metric
        getWeather(parameters: parameters, completionHandler: completionHandler)
    }

    func getWeatherByCoord(lat: String, lon: String, completionHandler: @escaping (ModelWeather?, Error?) -> ()){
        let parameters:[String:String] = ["lat":lat,
                                          "lon": lon,
                                          "units": "metric",
                                          "appid":self.apiKey]
        getWeather(parameters: parameters, completionHandler: completionHandler)
    }
    
    private func getWeather(parameters:[String:String], completionHandler: @escaping (ModelWeather?, Error?) -> ()){
            Alamofire.request(self.url, method: .get, parameters: parameters)
                .validate()
                .response { response in
                    if let error = response.error{
                        completionHandler(nil, error)
                    }
                    // convert data to our model and update the local variable
                    guard let responseData =  response.data else {
                        return completionHandler(nil, nil)
                    }
                    
                    do {
                        let json = try JSON(data: responseData)
                        let jsonMainTemp = json["main"]
                        var model = ModelWeather()
                        model.name = json["name"].stringValue
                        model.temp = jsonMainTemp["temp"].double ?? 0
                        model.tempMax = jsonMainTemp["temp_max"].double ?? 0
                        model.tempMin = jsonMainTemp["temp_min"].double ?? 0
                        completionHandler(model, nil)
                    }catch {
                        completionHandler(nil, error)
                        print("some thing went wrong.")
                    }
            }
    }
    
}
