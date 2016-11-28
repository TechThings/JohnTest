//
//  PromoTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PromoTableViewCellViewModel: ViewModel {
    let expireDate = Variable("")
    let promoCode = Variable("")
    let hideConditionLabel = Variable(false)
    let discountDescription = Variable("")
    let hideAmount = Variable(false)
    let discount = Variable("")

    init(promo: Promo) {
        super.init()
        if let promoDate = promo.expiryDatetime?.PromoDateString {
            expireDate.value = promoDate
        } else {
            expireDate.value = "∞"
        }
        promoCode.value = promo.code
        hideConditionLabel.value = !promo.isForFirstPurchaseOnly
        if let discountDescriptionUserVisible = promo.discountDescriptionUserVisible {
            discountDescription.value = discountDescriptionUserVisible
        }
        if promo.discountUserVisible.isEmpty {
            hideAmount.value = true
        }
        discount.value = promo.discountUserVisible
    }
}
