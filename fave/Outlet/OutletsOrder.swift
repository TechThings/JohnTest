//
//  OutletOrder.swift
//  KFIT
//
//  Created by Nazih Shoura on 14/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

enum OutletsOrder: Int {
    case ByDistance = 0
//    case ByRatings
    case ByFavorited

    var APIString: String {
        switch self {
        case .ByDistance: return "distance"
//        case .ByRatings: return "ratings"
        case .ByFavorited: return "favorited"
        }
    }
}
