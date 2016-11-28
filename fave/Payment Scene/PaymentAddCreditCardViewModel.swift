//
//  PaymentAddCreditCardViewModel.swift
//  fave
//
//  Created by Michael Cheah on 7/10/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MidtransKit
import MidtransCoreKit

protocol PaymentAddCreditCardViewModelDelegate: class {
    func presentPaymentViewController(viewController: UIViewController)
}

/**
 *  @author Michael Cheah
 *
 *  PaymentAddCreditCardViewModel
 */

final class PaymentAddCreditCardViewModel: ViewModel {

    // MARK:- Dependency
    private let cityProvider: CityProvider
    let paymentService: PaymentService
    let settingsProvider: SettingsProvider

    // MARK- Delegate
    weak var delegate: PaymentAddCreditCardViewModelDelegate!

    // MARK- Output
    var paymentMethodIdenfier: String = ""
    var primaryPaymentMethod: PaymentMethod? = nil
    let addedPaymentMathod: Variable<PaymentMethod?> = Variable(nil)

    // MARK:- Input
    let addPaymentMethodButtonDidTap: PublishSubject<()> = PublishSubject(())

    init(cityProvider: CityProvider = cityProviderDefault
         , paymentService: PaymentService = paymentServiceDefault
         , primaryPaymentMethod: PaymentMethod?
        , settingsProvider: SettingsProvider = settingsProviderDefault) {
        self.settingsProvider = settingsProvider
        self.cityProvider = cityProvider
        self.paymentService = paymentService

        if let primaryPaymentMethod = primaryPaymentMethod {
            self.primaryPaymentMethod = primaryPaymentMethod
            let methodKind = primaryPaymentMethod.kind
            let methodIdentifier = primaryPaymentMethod.identifier
            if (methodKind == "paypal") {
                self.paymentMethodIdenfier = methodIdentifier
            } else {
                self.paymentMethodIdenfier = "•••• •••• •••• " + methodIdentifier
            }
        }

        super.init()

        addPaymentMethodButtonDidTap
            .flatMap { [weak self] _ -> Observable<PaymentMethod?> in
                guard let strongself = self else {
                    throw PaymentViewModelError.AddPaymentFailed
                }
                return strongself.paymentService.addPaymentMethodFlow()
            }
            .bindTo(addedPaymentMathod)
            .addDisposableTo(disposeBag)
            /*
         .flatMap { [weak self] _ -> Observable<UIViewController> in
         guard let strongself = self else {
         throw PaymentViewModelError.AddPaymentFailed
         }
         return strongself.paymentService.addPaymentMethodViewController()
         }
         .doOnError { [weak self] (error: ErrorType) in
         self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
         let alertController = UIAlertController.alertController(forError: PaymentViewModelError.AddPaymentFailed)
         viewController.presentViewController(alertController, animated: true, completion: nil)
         }
         }
         .subscribeNext { [weak self] (addPaymentViewController: UIViewController) in
         self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
         viewController.navigationController?.presentViewController(addPaymentViewController, animated: true, completion: nil)
         }
        }
         */

    }
}
