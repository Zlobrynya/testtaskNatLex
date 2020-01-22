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
    var lastModelsWeather: ReplaySubject<[ModelWeather]>? = ReplaySubject.create(bufferSize: 2)
    private var modelsWeather = [ModelWeather]()
    private var modelWeatherOnMain = ModelWeather()
    
    init() {
        getLastData()
    }
    
    func getWeatherCity(_ city: String){
        if let obs = ServerModel().getWeatherAtCity(city){
            subscribeObservable(obs)
        }
    }
    
    func getWeatherByCoord(lat: String, lon: String){
        if let obs = ServerModel().getWeatherByCoord(lat: lat, lon: lon){
            subscribeObservable(obs)
        }
    }
    
    func getLastData(){
        let weathers = AcessCodeData.sharedInstance.getLastCoreData()
        lastModelsWeather?.onNext(weathers)
        modelsWeather += weathers
    }
    
    func updateInfo(){
        self.modelWeather?.onNext(modelWeatherOnMain)
    }
    
    private func subscribeObservable(_ observable: Observable<ModelWeather>){
        _ = observable.subscribe{ event in
            if let error = event.error{
                self.error?.onNext(error)
            }
            
            if let element = event.element{
                self.modelWeather?.onNext(element)
                self.modelWeatherOnMain = element
                AcessCodeData.sharedInstance.addPostToCoreData(model: element)
                // Замена и обновление таблицы
                if let item = self.modelsWeather.firstIndex(where: { $0.name == element.name }){
                    var locEl = element
                    locEl.countUnique = self.modelsWeather[item].countUnique + 1
                    self.modelsWeather[item] = locEl
                }else{
                    self.modelsWeather.append(element)
                }
                self.lastModelsWeather?.onNext(self.modelsWeather)
            }
        }
    }
}
