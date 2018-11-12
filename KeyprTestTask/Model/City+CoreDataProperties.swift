//
//  City+CoreDataProperties.swift
//  KeyprTestTask
//
//  Created by User on 10.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//
//

import Foundation
import CoreData

extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var cityId: Int32
    @NSManaged public var cityName: String?
    @NSManaged public var countryName: String?
    @NSManaged public var orderId: Int64
    @NSManaged public var weather: Weather?

}
