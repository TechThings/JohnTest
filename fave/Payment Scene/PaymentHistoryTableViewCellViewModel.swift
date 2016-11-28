//
//  PaymentHistoryTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/28/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  PaymentHistoryTableViewCellViewModel
 */
final class PaymentHistoryTableViewCellViewModel: ViewModel {

    let paymentReceipt: PaymentReceipt

    // MARK- Output
    let creatDate: Driver<String>
    let price: Driver<String>
    let referenceId: Driver<String>
    let title: Driver<String>
    let status: Driver<String>

    init(paymentReceipt: PaymentReceipt) {
        self.paymentReceipt = paymentReceipt
        if let date = paymentReceipt.created_at.PromoDateString {
            creatDate = Driver.of(date)
        } else {
            creatDate = Driver.of("")
        }
        price = Driver.of(paymentReceipt.amount)
        referenceId = Driver.of(" - \(NSLocalizedString("receipt_id", comment: "")): \(paymentReceipt.reference_number)")
        title = Driver.of(paymentReceipt.offerName)
        status = Driver.of(paymentReceipt.title)
        super.init()
    }

    // MARK:- Life cycle
    deinit {

    }
}
