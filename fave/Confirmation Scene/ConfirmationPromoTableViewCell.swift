//
//  ReservationActionPriceTableViewCell.swift
//  KFIT
//
//  Created by Kevin Mun on 22/03/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift

final class ConfirmationPromoTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ConfirmationPromoViewModel!

    @IBOutlet weak var promoLabel: UILabel!
    @IBOutlet weak var promoSavingLabel: KFITLabel!

    @IBOutlet weak var changeButton: UIButton!
    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.changeButton.setTitle(NSLocalizedString("payment_receipt_change_text", comment: ""), forState: .Normal)

    }

    @IBAction func didTapChangePromoButton(sender: AnyObject) {
        viewModel
            .lightHouseService
            .navigate
            .onNext { (viewController) in
                let alertController = UIAlertController(title: NSLocalizedString("getting_started_promo_code_text", comment: ""), message: nil, preferredStyle: .Alert)
                alertController.addTextFieldWithConfigurationHandler(nil)

                let okAction = UIAlertAction(title: NSLocalizedString("msg_dialog_ok", comment: ""), style: UIAlertActionStyle.Default) {
                    [weak self](action) in
                    guard let textFields = alertController.textFields else {return}

                    if let promoTextField = textFields[safe: 0],
                        let text = promoTextField.text {
                        if !text.isEmpty {
                            self?.viewModel.didApplyPromoCode(text)
                        }
                    }
                }

                let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)

                alertController.addAction(okAction)
                alertController.addAction(cancelAction)

                viewController.presentViewController(alertController, animated: true, completion: nil)
        }

    }

}

// MARK:- ViewModelBinldable

extension ConfirmationPromoTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.promoCode.drive(promoLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.promoSaving.drive(promoSavingLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
    }
}
