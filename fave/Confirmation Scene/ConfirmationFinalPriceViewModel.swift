//
//  ConfirmationFinalPriceViewModel.swift
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
 *  ConfirmationFinalPriceViewModel
 */

final class ConfirmationFinalPriceViewModel: ViewModel {

    // MARK:- Input
    let listing: ListingType!
    let currentSlot: Variable<Int>!
    var pricingBySlot: [Int: PurchaseDetails]!

    // MARK- Output
    let label: String
    var finalPrice: Driver<String>!

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

        self.label = NSLocalizedString("confirmation_amount_payable_text", comment: "")

        super.init()

        self.finalPrice = currentSlot.asDriver()
        .map {
            [weak self] (slot: Int) -> String in
            guard let pricing = self?.pricingBySlot[slot] else {
                return ""
            }

            if let isFree = pricing.isFree {
                if isFree {
                    return "FREE"
                }
            }

            guard let total = pricing.totalChargeAmountUserVisible else {
                return ""
            }

            return total
        }
    }

    // MARK:- Life cycle
    deinit {

    }
}
