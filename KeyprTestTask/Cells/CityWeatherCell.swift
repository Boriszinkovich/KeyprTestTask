//
//  WeatherCell.swift
//  KeyprTestTask
//
//  Created by User on 10.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit
import Kingfisher

class CityWeatherCell: UITableViewCell {

    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessibilityIdentifier = UIAccessibilityIdentifiers.keyMainVCCellId
        self.tempLabel.accessibilityIdentifier = UIAccessibilityIdentifiers.keyTemperatureLabelId
    }
    
    func setCity(city: CityCellViewModel) {
        cityLabel.text = city.cityName
        weatherLabel.text = city.weatherDescription
        tempLabel.text = city.temperature
        if let weatherUrl = city.weatherUrl {
            weatherImageView.kf.setImage(with: weatherUrl)
        }
    }
}
