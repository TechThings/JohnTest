//
//  ConfirmationPromoViewModel.swift
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
 *  ConfirmationPromoViewModel
 */

@objc protocol ConfirmationPromoDidChangePromoCode {
    func confirmationPromoDidChangePromoCode()
}

final class ConfirmationPromoViewModel: ViewModel {

    // MARK:- Input
    var promoSaving: Driver<String>!
    var promoCode: Driver<String>!
    private let addPromoAPI: AddPromoAPI
    weak var delegate: ConfirmationPromoDidChangePromoCode?
    let userProvider: UserProvider
    let currentSlot: Variable<Int>!
    var pricingBySlot: [Int: PurchaseDetails]!
    let listing: ListingType

    init(listing: ListingType,
         currentSlot: Variable<Int>!,
         addPromoAPI: AddPromoAPI = AddPromoAPIDefault(),
         userProvider: UserProvider = userProviderDefault) {

        self.currentSlot = currentSlot
        self.addPromoAPI = addPromoAPI
        self.listing = listing

        pricingBySlot = [Int: PurchaseDetails]()
        if let values = listing.pricingBySlots {
            for value in values {
                pricingBySlot[value.slots] = value
            }
        }

        self.userProvider = userProvider

        super.init()
        self.promoCode = currentSlot.asDriver()
            .map {
                [weak self] (slot: Int) -> String in
                guard let pricing = self?.pricingBySlot[slot],
                    let promoString = pricing.promoCode else {
                    return ""
                }

                return promoString
        }

        self.promoSaving = currentSlot.asDriver()
            .map {
                [weak self] (slot: Int) -> String in
                guard let pricing = self?.pricingBySlot[slot],
                 let promoSavingString = pricing.promoSavingsUserVisible else {
                    return ""
                }

                return promoSavingString
        }

    }

    func didApplyPromoCode(promoCode: String?) {
        if let promoCode = promoCode {
            _ = addPromoAPI
                .addPromo(atCheckoutOfferId: listing.id, requestPayload: AddPromoAPIRequestPayload(code: promoCode))
                .asObservable()
                .trackActivity(app.activityIndicator)
                .subscribe(
                    onNext: { [weak self](response) in
                        if response.pricingBySlots.count > 0 {
                            self?.delegate?.confirmationPromoDidChangePromoCode()
                        }
                    }, onError: { [weak self](error) in
                        self?.lightHouseService
                            .navigate
                            .onNext({ (viewController) in
                                let alertVC = UIAlertController.alertController(forError: error)
                                viewController.presentViewController(alertVC, animated: true, completion: nil)
                            })
                    }).addDisposableTo(disposeBag)
        }
    }

    // MARK:- Life cycle
    deinit {

    }
}
