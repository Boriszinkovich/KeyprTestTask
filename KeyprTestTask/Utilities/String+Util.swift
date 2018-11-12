//
//  String+Localization.swift
//  KeyprTestTask
//
//  Created by User on 11.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//

import Foundation

extension String {
    
    func localized(withComment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
    
    func localized() -> String {
        return localized(withComment: "")
    }
    
    static func defaultIfNil(optionalString: String?, defaultString: String = "") -> String {
        let text: String
        if let unwrapped = optionalString {
            text = unwrapped
        } else {
            text = defaultString
        }
        return text
    }
}
