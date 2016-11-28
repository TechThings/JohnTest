//
//  PaymentViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum PaymentItemKind {
    case CreditCard
    case PaymentHistory

    var cellHeight: CGFloat {
        switch self {
        case .CreditCard:
            return 180
        case .PaymentHistory:
            return 70
        }
    }
}

final class PaymentItem {
    let itemType: PaymentItemKind
    let item: AnyObject?

    init(itemType: PaymentItemKind, item: AnyObject?) {
        self.item = item
        self.itemType = itemType
    }
}

/**
 *  @author Nazih Shoura
 *
 *  PaymentViewModel
 */

final class PaymentViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    private let cityProvider: CityProvider
    private let paymentMethodsAPI: PaymentMethodsAPI
    private let paymentReceiptAPI: PaymentReceiptsAPI
    let settingsProvider: SettingsProvider

    // MARK- Output
    let paymentHistory = Variable([PaymentReceipt]())
    let primaryPaymentMethod = Variable<PaymentMethod?>(nil)
    let paymentItems: Driver<[PaymentItem]>

    init(
        paymentReceiptAPI: PaymentReceiptsAPI = PaymentReceiptsAPIDefault()
        , cityProvider: CityProvider = cityProviderDefault
        , paymentMethodsAPI: PaymentMethodsAPI = PaymentMethodsAPIDefault()
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , settingsProvider: SettingsProvider = settingsProviderDefault
        ) {
        self.trackingScreen = trackingScreen
        self.paymentReceiptAPI = paymentReceiptAPI
        self.cityProvider = cityProvider
        self.paymentMethodsAPI = paymentMethodsAPI
        self.settingsProvider = settingsProvider
        paymentItems = Observable.combineLatest(
            primaryPaymentMethod.asObservable(),
            paymentHistory.asObservable(),
            resultSelector: { (primaryPaymentMethod, paymentHistory) -> [PaymentItem] in

                var paymentItems = [PaymentItem]()

                paymentItems.append(PaymentItem(itemType: .CreditCard, item: primaryPaymentMethod))
                let paymentHistoryItems = paymentHistory.map({return PaymentItem(itemType: .PaymentHistory, item: $0)})
                paymentItems += paymentHistoryItems

                return paymentItems
        }).asDriver(onErrorJustReturn: [PaymentItem]())

        super.init()
    }

}

extension PaymentViewModel: Refreshable {
    func refresh() {

        _ = paymentMethodsAPI
            .paymentsMethods(withRequestPayload: PaymentMethodsAPIRequestPayload())
            .trackActivity(app.activityIndicator)
            .asObservable()
            .subscribeNext({ [weak self] (respondPayload) in
                    if let method = respondPayload.paymentMethods.filter({$0.primary == true}).first {
                        self?.primaryPaymentMethod.value = method
                    }
                })
            .addDisposableTo(disposeBag)

        _ = paymentReceiptAPI
            .getReceipt(withRequestPayload: PaymentReceiptsAPIRequestPayload())
            .trackActivity(app.activityIndicator)
            .asObservable()
            .subscribe(
                onNext: { [weak self] in
                    self?.paymentHistory.value = $0.receipts
                }, onError: { [weak self] (error: ErrorType) in
                    let alertController = UIAlertController.alertController(forError: error)
                    self?.lightHouseService
                        .navigate
                        .onNext({ (viewController) in
                            viewController.presentViewController(alertController, animated: true, completion: nil)
                        })
                })
            .addDisposableTo(disposeBag)
    }
}

enum PaymentViewModelError: DescribableError {
    case AddPaymentFailed

    var description: String {
        switch self {
        case .AddPaymentFailed:
            return "Add Payment Failed"
        }
    }

    var userVisibleDescription: String {
        switch self {
        case .AddPaymentFailed:
            return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }
}
