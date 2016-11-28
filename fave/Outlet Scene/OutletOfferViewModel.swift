//
//  OutletOfferViewModel.swift
//  fave
//
//  Created by Michael Cheah on 7/13/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  OutletOfferViewModel
 */

final class OutletOfferViewModel: ViewModel {

    // MARK:- Input
    let listing: ListingType

    // MARK- Output
    let activityName: String
    let featureImage: NSURL?
    let originalPrice: String?
    let finalPrice: String?
    let nextClassSessionDateTime: String?

    init(listing: ListingType) {
        self.listing = listing

        self.activityName = listing.name
        self.featureImage = listing.featuredImage

        self.finalPrice = listing.purchaseDetails.finalPriceUserVisible

        if listing.purchaseDetails.savingsUserVisible != nil {
            self.originalPrice = listing.purchaseDetails.originalPriceUserVisible
        } else {
            self.originalPrice = nil
        }

        if let timeslot = listing as? ListingTimeSlot, classSession = timeslot.nextClassSession {
            self.nextClassSessionDateTime = classSession.startDateTime.timeslotTimeDateString
        } else {
            self.nextClassSessionDateTime = nil
        }
    }

    // MARK:- Life cycle
    deinit {

    }
}
