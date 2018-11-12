//
//  Weather+CoreDataProperties.swift
//  KeyprTestTask
//
//  Created by User on 10.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var weatherDescription: String?
    @NSManaged public var temperature: Double
    @NSManaged public var iconId: String?
    @NSManaged public var city: City?

}
