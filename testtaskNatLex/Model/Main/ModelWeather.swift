//
//  ModelWeather.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 21/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import Foundation

class ModelWeather {
    var name = ""
    var temp = 0.0
    var tempMin = 0.0
    var tempMax = 0.0
    var time: Date = Date()
    var countUnique = 1
    
    func changeMetric(isFarengate: Bool){
        print("isFarengate \(name) \(isFarengate) \(temp) \(temp.conventToCelsius()) \(temp.conventToFarengate())")
        temp = isFarengate ? temp.conventToFarengate() : temp.conventToCelsius()
        tempMin = isFarengate ? tempMin.conventToFarengate() : tempMin.conventToCelsius()
        tempMax = isFarengate ? tempMax.conventToFarengate() : tempMax.conventToCelsius()
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func conventToFarengate() -> Double{
        return ((self * (9/5)) + 32).rounded(toPlaces: 2)
    }
    
    func conventToCelsius() -> Double{
        return ((self - 32) * (5/9)).rounded(toPlaces: 2)
    }
    
    func convent(isFarengate: Bool) -> Double{
        return isFarengate ? conventToFarengate() : conventToCelsius()
    }
}
