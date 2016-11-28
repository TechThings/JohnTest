//
//  ListingOutletViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ListingOutletViewModel
 */
final class ListingOutletViewModel: ViewModel {

    // MARK:- Input
    let listing: ListingType

    let openOutletButtonDidTap = PublishSubject<Void>()

    let openOutlet = PublishSubject<(Outlet, Company)>()

    // MARK- Output
    let listingName: Driver<String>
    let currentPrice: Driver<String>
    let originalPrice: Driver<String>

    init(
        listing: ListingType
        ) {
        self.listing = listing
        listingName = Driver.of("\(listing.name)")

        if (listing.purchaseDetails.savingsUserVisible != nil) {
            currentPrice = Driver.of(listing.purchaseDetails.discountPriceUserVisible)
            originalPrice = Driver.of(listing.purchaseDetails.originalPriceUserVisible)
        } else {
            currentPrice = Driver.of(listing.purchaseDetails.originalPriceUserVisible)
            originalPrice = Driver.of("")
        }

        super.init()
        openOutletButtonDidTap
            .map { return (listing.outlet, listing.company)}
            .bindTo(openOutlet)
            .addDisposableTo(disposeBag)
    }

    // MARK:- Life cycle
    deinit {

    }
}
