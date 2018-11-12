//
//  Weather+APIResponse.swift
//  KeyprTestTask
//
//  Created by User on 10.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//

import Foundation
import CoreData

extension Weather {
    convenience init(apiDictionary: [String: AnyObject]) throws {
        let managedObjectContext = CoreDataStack.sharedInstance.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Weather", in: managedObjectContext) else {
            fatalError();
        }
        guard let weatherArray = apiDictionary["weather"] as? [[String: AnyObject]],
            let weatherDict = weatherArray.first,
            let description = weatherDict["description"] as? String,
            let icon = weatherDict["icon"] as? String,
            let mainDict = apiDictionary["main"],
            let temperature = mainDict["temp"] as? Double else {
                throw WeatherServiceError.ApiError(message: "Incorrect data was loaded. Parsing failed.")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        self.temperature = temperature
        self.weatherDescription = description
        self.iconId = icon
    }
}
