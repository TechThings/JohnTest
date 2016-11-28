//
//  ReservationActionPriceTableViewCell.swift
//  KFIT
//
//  Created by Kevin Mun on 22/03/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift

final class ConfirmationPromoEmptyTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ConfirmationPromoViewModel!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBOutlet weak var havePromoButton: UIButton! {
        didSet {
            self.havePromoButton.setTitle(NSLocalizedString("getting_started_have_promo_code_text", comment: ""), forState: .Normal)
        }
    }

    @IBAction func didTapChangePromoButton(sender: AnyObject) {
        if viewModel.userProvider.currentUser.value.isGuest {
            let vm = EnterPhoneNumberViewControllerViewModel(enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality.LoginAGuestUser)
            let vc = EnterPhoneNumberViewController.build(vm)
            let nvc = RootNavigationController.build(RootNavigationViewModel())
            nvc.setViewControllers([vc], animated: false)
            UIViewController.currentViewController?.presentViewController(nvc, animated: true, completion: nil)
        } else {
            self.viewModel
                .lightHouseService
                .navigate
                .onNext { (viewController) in
                    let alertController = UIAlertController(title: NSLocalizedString("more_promo_code_title_text", comment: ""), message: nil, preferredStyle: .Alert)
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

}

// MARK:- ViewModelBinldable

extension ConfirmationPromoEmptyTableViewCell: ViewModelBindable {
    func bind() {
    }
}
