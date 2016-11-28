//
//  ListingBuyNowTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ListingBuyNowTableViewCellViewModel: ViewModel {
    let dateText = Variable("")
    let slotLeftText: String
    let slotLeftHidden: Bool
    let soldOut: Bool

    init(listingOpenVoucher: ListingOpenVoucherType) {
        guard let voucher = listingOpenVoucher.voucherDetail
        else {
            dateText.value = ""
            slotLeftText = ""
            slotLeftHidden = true
            soldOut = true
            super.init()
            return
        }

        if let dateString = voucher.validityEndDateTime.PromoDateString {
            dateText.value = String(format:NSLocalizedString("redeem_until_today", comment: ""), dateString)
        } else {
            dateText.value = ""
        }

        if voucher.purchaseSlots < 5 {
            slotLeftText = "\(voucher.purchaseSlots) " + NSLocalizedString("left", comment: "")
            slotLeftHidden = false
        } else {
            slotLeftText = ""
            slotLeftHidden = true
        }

        soldOut = voucher.purchaseSlots < 1

        super.init()
    }
}
