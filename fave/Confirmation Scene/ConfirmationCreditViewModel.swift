//
//  ConfirmationCreditViewModel.swift
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
 *  ConfirmationCreditViewModel
 */

final class ConfirmationCreditViewModel: ViewModel {

    // MARK:- Input
    let listing: ListingType!
    let currentSlot: Variable<Int>!
    var pricingBySlot: [Int: PurchaseDetails]!

    // MARK- Output
    let label: String
    var creditUsed: Driver<String>!

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

        self.label = NSLocalizedString("confirmation_credit_used_text", comment: "")

        super.init()

        self.creditUsed = currentSlot.asDriver()
            .map {
                [weak self] (slot: Int) -> String in
                guard let pricing = self?.pricingBySlot[slot] else {
                    return ""
                }

                guard let creditUsedString = pricing.creditUsed else {
                    return ""
                }

                return "\(creditUsedString)"
        }
    }

    // MARK:- Life cycle
    deinit {

    }
}
