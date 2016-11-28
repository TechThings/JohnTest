//
//  ListingsOrder.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

enum ListingsOrder: Int {
    case ByDistance = 0
    case ByTrending
    case ByPrice

    var APIString: String {
        switch self {
        case .ByDistance :
            return "distance"
        case .ByTrending:
            return "trending"
        case .ByPrice:
            return "price"
        }
    }

    var userVisibleString: String {
        switch self {
        case .ByDistance :
            return NSLocalizedString("sort_by_distance_option", comment: "")
        case .ByTrending:
            return NSLocalizedString("sort_by_trending_option", comment: "")
        case .ByPrice:
            return NSLocalizedString("sort_by_price_option", comment: "")
        }
    }
}
