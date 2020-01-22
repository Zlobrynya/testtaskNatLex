//
//  AcessCodeData.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 22/01/2020.
//  Copyright © 2019 Zappa. All rights reserved.
//

import UIKit
import CoreData


class AcessCodeData {
    //CoreDate
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var container: NSPersistentContainer!
    private var context: NSManagedObjectContext!
    
    static let sharedInstance = AcessCodeData()
    
    init() {
        container = appDelegate.persistentContainer
        context = container.viewContext
    }

    func addPostToCoreData(model weatherModel: ModelWeather){
        let post = NSEntityDescription.entity(forEntityName: "Weather", in: context)
        let weather = NSManagedObject(entity: post!, insertInto: context) as! Weather
        weather.city = weatherModel.name
        weather.temp = weatherModel.temp
        weather.max_temp = weatherModel.tempMax
        weather.min_temp = weatherModel.tempMin
        weather.time = weatherModel.time
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func getLastCoreData() -> [ModelWeather]{
        var weathrs = [ModelWeather]()
        
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest<NSDictionary>(entityName: "Weather")
        request.propertiesToFetch = ["city"]
        request.returnsDistinctResults = true
        request.resultType = .dictionaryResultType

        do {
            let lists: [NSDictionary] = try context.fetch(request)
            for item in lists{
                print("getAll \(item) \(lists.count)")
                if let city = item["city"] as? String,
                    let weather = getLastWeather(city: city){
                    weathrs.append(weather)
                }
            }
            return weathrs
        } catch {}
        return [ModelWeather]()
    }
    
    private func getLastWeather(city: String) -> ModelWeather?{
        let request: NSFetchRequest<Weather> = Weather.fetchRequest()
        request.predicate = NSPredicate(format: "city = %@", city)
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false, selector: nil)]
        do {
            let lists = try context.fetch(request)
            var modelWeather = ModelWeather()
            modelWeather.name = lists[0].city ?? ""
            modelWeather.temp = lists[0].temp
            modelWeather.tempMax = lists[0].max_temp
            modelWeather.tempMin = lists[0].min_temp
            modelWeather.time = lists[0].time ?? Date()
            modelWeather.countUnique = lists.count
            return modelWeather
        } catch {}
        return nil
    }
}
