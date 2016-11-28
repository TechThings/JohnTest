//
//  AddPaymentMethodViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  AddPaymentMethodViewControllerViewModel
 */
final class AddPaymentMethodViewControllerViewModel: ViewModel {

    // MARK:- Dependency
    let resultSubject: PublishSubject<PaymentMethod?>
    let adyenPayment: AdyenPaymentFacade
    // MARK:- Input
    let cancelButtonDidTap: PublishSubject<()> = PublishSubject(())

    init(resultSubject: PublishSubject<PaymentMethod?>, adyenPayment: AdyenPaymentFacade) {
        self.resultSubject = resultSubject
        self.adyenPayment = adyenPayment
        super.init()

        cancelButtonDidTap.subscribeNext { [weak self] _ in
            self?.resultSubject.onCompleted()
            self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                viewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }.addDisposableTo(disposeBag)
    }
}
