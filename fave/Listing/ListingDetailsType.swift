//
//  ListingDetailsType.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

enum RedemptionMethod: String {
    case  voucherCode = "voucher_code"
    case  swipe = "swipe"
    case  paperVoucher = "paper_voucher"
}

extension RedemptionMethod: Defaultable {
    static var defaultValue: RedemptionMethod {
        return .swipe
    }
}

protocol ListingDetailsType: ListingType {
    var paymentGateways: [PaymentGateway] { get }
    var primaryPaymentGateway: PaymentGateway { get }
    var redemptionInstructions: String? { get }
    var redemptionMethod: RedemptionMethod { get }
}
