//
//  PendingPaymentReservationViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  PendingPaymentReservationViewModel
 */
final class PendingPaymentReservationViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let paymentService: PaymentService
    private let assetProvider: AssetProvider

    // MARK:- Input
    let reservation: Reservation

    // MARK- Output
    let payButtonDidTap = PublishSubject<Void>()

    // IBOutlet variable
    let profilePictureViewModel: Driver<AvatarViewModel>
    let quantity: Driver<String>
    let pendingPaymentTitle: Driver<String>
    let pendingPaymentDescription: Driver<String>
    let payNowUserHidden: Driver<Bool>
    let payButtonTitle: Driver<String>
    let userName: Driver<String>
    let appImage: Driver<UIImage?>

    // IBOutlet static
    let userNameStatic = Driver.of(NSLocalizedString("name", comment: ""))
    let quantityStatic = Driver.of(NSLocalizedString("purchase_detail_quantity_text", comment: ""))

    init(
        userProvider: UserProvider = userProviderDefault
        , reservation: Reservation
        , paymentService: PaymentService = PaymentServiceDefault()
        , assetProvider: AssetProvider = assetProviderDefault
        ) {
        self.reservation = reservation
        self.userProvider = userProvider
        self.paymentService = paymentService
        self.assetProvider = assetProvider

        appImage = assetProvider.imageAssest.asDriver().map({ (imgAsset: ImageAssest) -> UIImage? in
            imgAsset.aboutImage
        })

        self.profilePictureViewModel = userProvider
            .currentUser
            .asDriver()
            .map({ (user) -> AvatarViewModel in
                return AvatarViewModel(initial: user.name, profileImageURL: user.profileImageURL)
            })

        self.userName = userProvider
            .currentUser
            .asDriver()
            .map({ (user) -> String in
                if let name = user.name {
                    return name
                } else {
                    return ""
                }
            })

        quantity = Driver.of("\(NSLocalizedString("confirmation_quantity_text", comment: "")): \(reservation.slotsReserved == 1 ? "1 \((NSLocalizedString("voucher", comment: "")))": "\(reservation.slotsReserved) \(NSLocalizedString("vouchers", comment: ""))")")

        pendingPaymentTitle = Driver.of("\(NSLocalizedString("purchase_detail_payment_pending_title_text", comment: ""))")

        if let expiringDateString = reservation.expiringAt?.RefundEndDateString {
            pendingPaymentDescription = Driver.of("\(NSLocalizedString("please_complete_your_payment", comment: "")) \(expiringDateString) \(NSLocalizedString("to_confirm_your_purchase", comment: ""))")
        } else {
            pendingPaymentDescription = Driver.of("")
        }

        payNowUserHidden = Driver.of(reservation.expiringAt?.timeIntervalSince1970 <= NSDate().timeIntervalSince1970)

        payButtonTitle = Driver.of(NSLocalizedString("purchase_detail_pay_now_text", comment: ""))

        super.init()

        payButtonDidTap
            .subscribeNext { [weak self] _ in
                // The payButtonDidTap signal sould not be triggered if payment has been setteled anyway
                self?.pay()
            }
            .addDisposableTo(disposeBag)
    }

    func pay() {
        let payingConfiguration = PayingConfiguration.create(fromReservation: reservation)

        paymentService
            .performPayment(withPaymentConfiguration: payingConfiguration)
            .doOnError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            .subscribe()
            .addDisposableTo(disposeBag)
    }
}
