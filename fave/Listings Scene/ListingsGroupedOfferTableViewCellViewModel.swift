//
//  ListingsGroupedOfferTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  ListingsGroupedOfferTableViewCellViewModel
 */
final class ListingsGroupedOfferTableViewCellViewModel: ViewModel {

    // MARK- Output
    let activityName: Driver<String>
    let activityImage: Driver<NSURL?>
    let originalPrice: Driver<String>
    let officialPrice: Driver<String>

    let listing: ListingUserVisible
    let outlet: Outlet
    let cellHeight: CGFloat

    init(
        listing: ListingUserVisible,
        outlet: Outlet
        ) {
        self.listing = listing
        self.outlet = outlet
        self.activityName  = Driver.of(listing.name)
        self.activityImage = Driver.of(listing.featuredThumbnailImage)
        self.originalPrice = Driver.of(listing.purchaseDetails.originalPriceUserVisible)
        self.officialPrice = Driver.of(listing.purchaseDetails.finalPriceUserVisible)

        var font = UIFont.systemFontOfSize(15)
        if let circularFont = UIFont(name: "CircularStd-Book", size: 15) {
            font = circularFont
        }
        self.cellHeight = max(listing.name.heightWithConstrainedWidth(UIScreen.mainWidth - 150, font: font) + 50, 95)

        super.init()

    }
}
