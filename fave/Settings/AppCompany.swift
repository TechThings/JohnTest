//
//  AppCompany.swift
//  FAVE
//
//  Created by Gautam on 05/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

// This final class is to define the app company for the product. For now, we have Fave and Groupon.

enum AppCompany: String {
    case kfit = "KFIT"
    case groupon = "Groupon"

}

extension AppCompany: Defaultable {
    static var defaultValue: AppCompany {
        if let langCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String {
            if langCode == "ID" {
                return AppCompany.groupon
            }
        }
        return AppCompany.kfit
    }
}
