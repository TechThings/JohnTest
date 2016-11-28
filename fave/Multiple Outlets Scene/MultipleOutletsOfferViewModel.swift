//
//  MultipleOutletsOfferViewModel.swift
//  FAVE
//
//  Created by Syahmi Ismail on 19/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MultipleOutletsOfferViewModel: ViewModel {

    // MARK- Output
    let offerName: Driver<String>
    let offerImage: Driver<NSURL?>
    let ratingString: Driver<String>
    let ratingHidden: Driver<Bool>
    let totalOutlet: Driver<String>

    init(
        listing: ListingType
        ) {
        self.offerName = Driver.of(listing.name)
        self.offerImage = Driver.of(listing.featuredImage)
        self.ratingString = Driver.of(String(listing.company.averageRating))
        let rating = listing.company.averageRating
        if rating < 3.5 {
            self.ratingHidden = Driver.of(false)
        } else {
            self.ratingHidden = Driver.of(true)
        }
        if let totalRedeemableOutlets = listing.totalRedeemableOutlets {
            if totalRedeemableOutlets > 1 {
                self.totalOutlet = Driver.of("\(totalRedeemableOutlets) \(NSLocalizedString("locations", comment: ""))")
            } else if totalRedeemableOutlets == 1 {
                self.totalOutlet = Driver.of("\(totalRedeemableOutlets) \(NSLocalizedString("location", comment: ""))")
            } else {
                self.totalOutlet = Driver.of("")
            }
        } else {
            self.totalOutlet = Driver.of("")
        }

        super.init()

    }
}
