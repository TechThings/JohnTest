//
// Created by Michael Cheah on 7/10/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Braintree

final class PaymentAddCreditCardTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: PaymentAddCreditCardViewModel!

    @IBOutlet weak var creditCardHightConstraint: NSLayoutConstraint!
    // MARK:- IBOutlets
    @IBOutlet weak var creditCardLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var noMethodButton: UIButton!
    @IBOutlet weak var cardImageView: UIImageView!

    @IBAction func editButtonDidTap(sender: AnyObject) {
        viewModel.addPaymentMethodButtonDidTap.onNext()
    }

    @IBAction func noMethodButtonDidTap(sender: AnyObject) {
        viewModel.addPaymentMethodButtonDidTap.onNext()
    }
}

// MARK:- ViewModelBinldable

extension PaymentAddCreditCardTableViewCell: ViewModelBindable {
    func bind() {
        // FIXME: Add real card image
        self.noMethodButton.hidden = false
        self.cardView.hidden = true
        self.cardImageView.hidden = true
        self.editButton.setTitle(NSLocalizedString("payment_receipt_change_text", comment: ""), forState: .Normal)
        creditCardLabel.text =  viewModel.paymentMethodIdenfier
        if viewModel.primaryPaymentMethod != nil {
            self.noMethodButton.hidden = true
            self.cardImageView.hidden = false
            self.cardView.hidden = false
        }

        if viewModel.settingsProvider.settings.value.appCompany == AppCompany.groupon {
            creditCardHightConstraint.constant = 0
            setNeedsLayout()
            layoutIfNeeded()
        }

        viewModel
            .addedPaymentMathod
            .asObservable()
            .delaySubscription(2.0, scheduler: MainScheduler.instance)
            .subscribeNext {
                [weak self] (method: PaymentMethod?) in

                if let method = method {
                    let methodKind = method.kind

                    if (methodKind == "paypal") {
                        self?.creditCardLabel.text = method.identifier
                    } else {
                        self?.creditCardLabel.text = "•••• •••• •••• " + method.identifier
                    }

                    self?.noMethodButton.hidden = true
                    self?.cardImageView.hidden = false
                    self?.cardView.hidden = false
                }
            }
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
