//
//  City+CoreDataClass.swift
//  KeyprTestTask
//
//  Created by User on 10.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//
//

import Foundation
import CoreData

public class City: NSManagedObject {
    
    static func createCity(id: Int32, name: String, countryName: String) -> City {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let cityEntity = NSEntityDescription.insertNewObject(forEntityName: "City", into: context) as? City {
            cityEntity.cityId = id
            cityEntity.cityName = name
            cityEntity.countryName = countryName
            // set autoincrement value
            cityEntity.updateOrderId()
            return cityEntity
        }
        fatalError("Database error!!!")
    }
    
    static var lastOrderId: Int64 {
        get {
            return Int64(UserDefaults.standard.integer(forKey: "lastOrderId"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastOrderId")
        }
    }
    
    private func updateOrderId() {
        var lastOrderId = City.lastOrderId
        self.orderId = lastOrderId
        lastOrderId += 1
        City.lastOrderId = lastOrderId
    }
}
