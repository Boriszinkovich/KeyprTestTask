//
//  CityViewModel.swift
//  KeyprTestTask
//
//  Created by User on 11.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//

import Foundation

// ViewModel for City cell
struct CityCellViewModel {
    
    let cityName: String
    let temperature: String
    let weatherDescription: String
    let weatherUrl: URL?
    
    init(city: City, api: APIService) {
        
        if let cityName = city.cityName, let countryName = city.countryName {
            self.cityName = cityName + ", " + countryName
        } else {
            self.cityName = "-||-"
        }
        guard let weather = city.weather else {
            self.temperature = "-||-"
            self.weatherDescription = "-||-"
            self.weatherUrl = nil
            return
        }
        self.temperature = String(Int(round(weather.temperature))) + "°"
        self.weatherDescription = String.defaultIfNil(optionalString: weather.weatherDescription?.capitalized,
                                                      defaultString: "-||-")
        self.weatherUrl = (weather.iconId != nil) ? api.getIconWeatherUrl(icon: weather.iconId!) : nil
    }
}
