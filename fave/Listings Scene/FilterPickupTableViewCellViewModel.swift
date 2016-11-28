//
//  FilterPickupTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

class FilterPickupTableViewCellViewModel: ViewModel {
    let orderButtonTitle: String
    let countPlaceNearbyLabelText: String

    init(order: ListingsOrder, count: Int) {
        orderButtonTitle = "Sort by \(order.APIString.capitalizingFirstLetter())"
        if count <= 0 {
            countPlaceNearbyLabelText = ""
        } else if count == 1 {
            countPlaceNearbyLabelText = "1 place nearby"
        } else {
            countPlaceNearbyLabelText = "\(count) places nearby"
        }
    }
}
