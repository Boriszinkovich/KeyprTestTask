//
//  WeatherService.swift
//  KeyprTestTask
//
//  Created by Borys Zinkovych on 11/8/18.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit
import CoreData

protocol WeatherServiceProtocol {
    func loadWeatherIfRequired() -> Bool
    func forceLoadWeather() -> Bool
}

protocol WeatherServiceDelegate: NSObjectProtocol {
    func weatherServiceDidStartLoading()
    func weatherServiceDidFinishLoading()
    func weatherServiceFailedLoading(error: WeatherServiceError)
}

enum WeatherServiceError: Error {
    case NetworkError(message: String)
    case ApiError(message: String)
}

class WeatherService: NSObject, WeatherServiceProtocol {
    
    weak var delegate: WeatherServiceDelegate?
    var fetchCompletion: ((UIBackgroundFetchResult) -> Void)?
    
    public private(set) var api: APIService
    private var cities: [City] = []
    private var isLoading: Bool = false
    
    init(api: APIService) {
        self.api = api
        super.init()
        cities = loadCitiesFromDB()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: NetworkManager.sharedInstance.reachability
        )
    }
    
    func loadWeatherIfRequired() ->Bool {
        if self.isLoading || !NetworkManager.isReachable() {
            return false
        }
        guard let lastUpdateDate = self.lastUpdateDate else {
            self.loadWeatherData()
            return true
        }
        let updateInterval: TimeInterval = 3 * 5 // 5 minutes
        if Date().timeIntervalSince(lastUpdateDate) > updateInterval {
            self.loadWeatherData()
            return true
        }
        return false
    }
    
    func forceLoadWeather() -> Bool {
        if self.isLoading || !NetworkManager.isReachable() {
            return false
        }
        self.loadWeatherData()
        return true
    }
}

private typealias StoredProperties = WeatherService
extension StoredProperties {
    
    var isFirstInstall: Bool{
        get {
           return UserDefaults.standard.bool(forKey: "isFirstInstall")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFirstInstall")
        }
    }
    var lastUpdateDate: Date?{
        get {
            return UserDefaults.standard.object(forKey: "date") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "date")
        }
    }
}

private typealias PrivateMethods = WeatherService
private extension PrivateMethods {
    
    private func loadWeatherData() {
        self.isLoading = true
        delegate?.weatherServiceDidStartLoading()
        api.getCurrentWeatherData(cities: cities) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .Success(let data):
                    self.updateWeather(data: data)
                case .Error(let message):
                    self.adjustError(error: .ApiError(message: message))
                }
            }
        }
    }
    
    private func updateWeather(data: [[String: AnyObject]]) {
        do {
            for apiItem in data {
                try updateWeather(apiItem: apiItem)
            }
        } catch let error as WeatherServiceError {
            adjustError(error: error)
        } catch _ {
            print("unrecognized error was thrown")
        }
        lastUpdateDate = Date()
        CoreDataStack.sharedInstance.saveContext()
        self.isLoading = false
        delegate?.weatherServiceDidFinishLoading()
        if let fetchCompletion = fetchCompletion {
            fetchCompletion(.newData)
            self.fetchCompletion = nil
        }
    }
    
    private func updateWeather(apiItem: [String: AnyObject]) throws {
        guard let cityId = apiItem["id"] as? Int else {
            throw WeatherServiceError.ApiError(message: "Can not parse loaded data")
        }
        for city in cities {
            if city.cityId == cityId {
                let weather = try Weather(apiDictionary: apiItem)
                if let oldWeather = city.weather {
                    CoreDataStack.sharedInstance.persistentContainer.viewContext.delete(oldWeather)
                }
                weather.city = city
                city.weather = weather
                break;
            }
        }
    }
    
    private func adjustError(error: WeatherServiceError) {
        var error = error
        if !NetworkManager.isReachable() {
            error = WeatherServiceError.NetworkError(message: "No network connection!")
        }
        self.isLoading = false
        self.delegate?.weatherServiceFailedLoading(error: error)
        if let fetchCompletion = fetchCompletion {
            fetchCompletion(.noData)
            self.fetchCompletion = nil
        }
    }
    
    @objc private func networkStatusChanged(_:Notification) {
        DispatchQueue.main.async {
            if NetworkManager.isReachable() {
                _ = self.forceLoadWeather()
            }
        }
    }
    
    private func loadCitiesFromDB() -> [City] {
        if !isFirstInstall {
            let cities = createCities()
            isFirstInstall = true
            return cities
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(request)
            guard let cityResult = result as? [City] else {
                fatalError("DB fatal error")
            }
            return cityResult
        } catch _ {
            fatalError("DB fatal error")
        }
    }
    
    private func createCities() -> [City] {
        var array:[City] = []
        array.append(City.createCity(id: 2643743, name: "London", countryName: "GB"))
        array.append(City.createCity(id: 6167865, name: "Toronto", countryName: "CA"))
        array.append(City.createCity(id: 703448, name: "Kyiv", countryName: "UA"))
        CoreDataStack.sharedInstance.saveContext()
        return array
    }
}
