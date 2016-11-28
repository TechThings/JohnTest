//
//  ListingDetailsTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingDetailsTableViewCellViewModel: ViewModel {
    let title = Variable("")
    let distance = Variable("")
    let currentPrice = Variable("")
    let originalPrice = Variable("")

    init(listing: ListingType) {
        super.init()
        title.value = listing.name
        distance.value = "\(listing.outlet.distanceKM!) km"
        if (listing.purchaseDetails.savingsUserVisible != nil) {
            currentPrice.value = listing.purchaseDetails.discountPriceUserVisible
            originalPrice.value = listing.purchaseDetails.originalPriceUserVisible
        } else {
            currentPrice.value = listing.purchaseDetails.originalPriceUserVisible
            originalPrice.value = ""
        }
    }
}
