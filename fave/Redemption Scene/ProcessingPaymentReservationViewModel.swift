//
//  ProcessingPaymentReservationViewModel.swift
//  FAVE
//
//  Created by Light Dream on 18/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ProcessingPaymentReservationViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let assetProvider: AssetProvider
    private let reservationInfoAPI: ReservationInfoAPI

    // MARK:- Input
    let reservation: Reservation

    // MARK- Output
    let refreshButtonDidTap = PublishSubject<Void>()
    let refreshedReservation = PublishSubject<Reservation>()

    // IBOutlet variable
    let profilePictureViewModel: Driver<AvatarViewModel>
    let quantity: Driver<String>
    let userName: Driver<String>
    let appImage: Driver<UIImage?>

    // IBOutlet static
    let userNameStatic = Driver.of(NSLocalizedString("name", comment: ""))
    let quantityStatic = Driver.of(NSLocalizedString("purchase_detail_quantity_text", comment: ""))

    init(
        userProvider: UserProvider = userProviderDefault
        , reservation: Reservation
        , reservationInfoAPI: ReservationInfoAPI = ReservationInfoAPIDefault()
        , assetProvider: AssetProvider = assetProviderDefault
        ) {
        self.reservation = reservation
        self.userProvider = userProvider
        self.reservationInfoAPI = reservationInfoAPI
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

//        processingPaymentTitle = Driver.of("\(NSLocalizedString("purchase_detail_payment_pending_title_text", comment: ""))")

//        if let expiringDateString = reservation.expiringAt?.RefundEndDateString {
//            processingPaymentDescription = Driver.of("\(NSLocalizedString("please_complete_your_payment", comment: "")) \(expiringDateString) \(NSLocalizedString("to_confirm_your_purchase", comment: ""))")
//        } else {
//            processingPaymentDescription = Driver.of("")
//        }
//        
//        refreshButtonTitle = Driver.of(NSLocalizedString("purchase_detail_pay_now_text", comment: ""))

        super.init()

        refreshButtonDidTap
            .subscribeNext { [weak self] _ in
                // The payButtonDidTap signal sould not be triggered if payment has been setteled anyway
//                let payingConfiguration = PayingConfiguration.create(fromReservation: reservation)
               self?.refresh()
//                self?.paymentService.performPayment(withPaymentConfiguration: payingConfiguration)
            }
            .addDisposableTo(disposeBag)
    }

    func refresh() {
        _ = reservationInfoAPI.getReservationInfo(withRequestPayload: ReservationInfoAPIRequestPayload(id: reservation.id))
            .asObservable()
            .trackActivity(app.activityIndicator)
            .doOnError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            .map { (respond: ReservationInfoAPIResponsePayload) -> Reservation in
                return respond.reservation
            }
            .subscribeNext({ (res: Reservation) in
                self.refreshedReservation.onNext(res)
            })
            .addDisposableTo(disposeBag)
    }
}
