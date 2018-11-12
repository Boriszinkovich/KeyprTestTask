//
//  UINavigationItem+LeftTitle.swift
//  KeyprTestTask
//
//  Created by User on 11.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit

extension UINavigationItem {
    
    func setLeftTitle(title: String, textColor: UIColor?, font: UIFont? = nil) {
        let label = UILabel()
        if let textColor = textColor {
            label.textColor = textColor
        }
        if let font = font {
            label.font = font
        }
        label.text = title;
        label.sizeToFit()
        self.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
}
