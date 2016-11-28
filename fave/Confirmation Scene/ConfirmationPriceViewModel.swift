//
//  ConfirmationPriceViewModel.swift
//  fave
//
//  Created by Michael Cheah on 7/8/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  ConfirmationPriceViewModel
 */

final class ConfirmationPriceViewModel: ViewModel {

    // MARK:- Input
    let listing: ListingType!
    let currentSlot: Variable<Int>!
    var pricingBySlot: [Int: PurchaseDetails]!

    // MARK- Output
    let label: String
    var originalPrice: Driver<String>!
    var currentPrice: Driver<String>!

    init(listing: ListingType!,
         currentSlot: Variable<Int>!) {
        self.listing = listing
        self.currentSlot = currentSlot

        pricingBySlot = [Int: PurchaseDetails]()
        if let values = listing.pricingBySlots {
            for value in values {
                pricingBySlot[value.slots] = value
            }
        }

        self.label = NSLocalizedString("confirmation_total_price_text", comment: "")

        super.init()

        self.originalPrice = currentSlot.asDriver()
        .map {
            [weak self] (slot: Int) -> String in
            if let pricing = self?.pricingBySlot[slot] where pricing.savingsUserVisible != nil {
                return pricing.originalPriceUserVisible
            }

            return ""
        }

        self.currentPrice = currentSlot.asDriver()
        .map {
            [weak self] (slot: Int) -> String in
            guard let pricing = self?.pricingBySlot[slot] else {
                return ""
            }

            return pricing.discountPriceUserVisible
        }
    }

    // MARK:- Life cycle
    deinit {

    }
}
