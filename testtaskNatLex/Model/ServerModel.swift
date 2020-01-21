//
//  ServerModel.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 21/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON

class ServerModel {
    private var apiKey = "7c64957ea897785f6db59d4c648c5d66"
    private var url = "https://api.openweathermap.org/data/2.5/weather?"
    
    func getWeatherAtCity(_ city: String) -> Observable<ModelWeather>?{
        return Observable<ModelWeather>.create({observer in
            let parameters:[String:String] = ["q":city,
                                              "appid":self.apiKey]
            Alamofire.request(self.url, method: .get, parameters: parameters)
                .validate()
                .response { response in
                    print("response.data \(response.error)")
                    if let error = response.error{
                        observer.onError(error)
                        return observer.onCompleted()
                    }
                    // convert data to our model and update the local variable
                    guard let responseData =  response.data else {
                        return observer.onCompleted()
                    }
                    
                    do {
                        let json = try JSON(data: responseData)
                        let jsonMainTemp = json["main"]
                        var model = ModelWeather()
                        model.name = json["name"].stringValue
                        model.temp = jsonMainTemp["temp"].double ?? 0
                        model.tempMax = jsonMainTemp["temp_max"].double ?? 0
                        model.tempMin = jsonMainTemp["temp_min"].double ?? 0
                        observer.onNext(model)
                        observer.onCompleted()
                    }catch {
                        observer.onError(error)
                        observer.onCompleted()
                        print("some thing went wrong.")
                    }
            }

            return Disposables.create();
        })
    }
    
}
