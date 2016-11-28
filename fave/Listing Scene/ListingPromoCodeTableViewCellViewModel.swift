//
//  ListingPromoCodeTableViewCellViewModel.swift
//  FAVE
//
//  Created by Gautam on 18/08/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ListingPromoCodeTableViewCellViewModel: ViewModel {

    // MARK:- Input
    var promoDescription: Driver<String>

    // MARK:- State

    // MARK- Output
    init(promoSavings: String?
        , promoCode: String?) {
        if let promoSavings = promoSavings, let promoCode = promoCode {
            self.promoDescription = Driver.of(String(format:NSLocalizedString("promo_description", comment: ""), promoCode, promoSavings))
        } else {
            self.promoDescription = Driver.of("")
        }

        super.init()
    }

    // MARK:- Intermediate

    // MARK:- Life cycle
    deinit {

    }
}
