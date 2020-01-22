//
//  Weather+CoreDataProperties.swift
//  
//
//  Created by Nikitin Nikita on 22/01/2020.
//
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var city: String?
    @NSManaged public var time: Date?
    @NSManaged public var temp: Double
    @NSManaged public var min_temp: Double
    @NSManaged public var max_temp: Double

}
