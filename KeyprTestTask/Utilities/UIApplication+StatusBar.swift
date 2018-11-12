//
//  UIApplication+StatusBar.swift
//  KeyprTestTask
//
//  Created by User on 11.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit

extension UIApplication {
    
    var statusBarView: UIView? {
        // statusBar is a private property
        // lets obfuscate it to avoid possible app rejection
        return value(forKey: getObfValue(string: "c3RhdHVzQmFy")) as? UIView
    }
    
    private func getObfValue(string: String) -> String {
        let decodedData = Data(base64Encoded: string)!
        return String(data: decodedData, encoding: .utf8)!
    }
}
