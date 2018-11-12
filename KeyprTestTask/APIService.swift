//
//  APIService.swift
//  KeyprTestTask
//
//  Created by Borys Zinkovych on 11/8/18.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit

class APIService: NSObject {

    let host = "http://api.openweathermap.org"
    let imageRequest = "/img/w"
    let currentDataRequest = "data"
    let apiVersion = "2.5"
    let groupOrder = "group"
    let appID = "a1d1dc41d71e2b1c1d329e64770bf088"
    lazy var appIdQuery: String = {
        return "appid="+appID
    }()
    
    func getIconWeatherUrl(icon: String) -> URL? {
        let query = host + imageRequest + "/" + icon + ".png"
        return URL(string: query)
    }
    
    func getCurrentWeatherData(cities:[City],  completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        if cities.count > 20 {
            return completion(.Error(message: "Invalid parameter"))
        }
        
        let citiesString = citiesGroupQuery(cities: cities)
        let query = host + "/" + currentDataRequest + "/" + apiVersion + "/" + groupOrder + "?id=" + citiesString + "&units=metric&" + appIdQuery
        
        guard let url = URL(string: query) else {
            return completion(.Error(message: "Invalid URL, can't update cities weather"))
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in

            guard error == nil else { return completion(.Error(message: error!.localizedDescription)) }
            guard let data = data else { return completion(.Error(message: "No data received"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    guard let itemsJsonArray = json["list"] as? [[String: AnyObject]] else {
                        return completion(.Error(message: "Invalid data received"))
                    }
                    completion(.Success(itemsJsonArray))
                }
            } catch let error {
                return completion(.Error(message: error.localizedDescription))
            }
            }.resume()
    }
    
    // MARK: - Helpers
    
    private func citiesGroupQuery(cities:[City])->String {
        var resultString = ""
        for city in cities {
            resultString = resultString + String(city.cityId) + ","
        }
        resultString.removeLast()
        return resultString
    }
}

enum Result<T> {
    case Success(T)
    case Error(message: String)
}


