//
//  RedeemableReservationViewModel.swift
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
 *  RedeemableReservationViewModel
 */
final class RedeemableReservationViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let redeemAPI: RedeemAPI

    private let assetProvider: AssetProvider

    // MARK:- Input
    let reservation: Reservation

    // MARK:- Output
    let redeemedReservation = PublishSubject<Reservation>()

    // MARK:- Multiple outlet trigger
    let redeemShowConfirm       = PublishSubject<Void>()
    let redeemCancelRequest     = PublishSubject<Void>()
    let redeemConfirmRequest    = PublishSubject<Void>()

    // IBOutlet variable
    let profilePictureViewModel: Driver<AvatarViewModel>
    let receiptID: Driver<String>
    let quantity: Driver<String>
    let redemtionDescription: Driver<String>
    let userName: Driver<String>
    let appImage: Driver<UIImage?>
    let redeemCode: Driver<String>
    let onlineRedeemDescription: Driver<String?>
    let hiddenOnlineRedeemView: Driver<Bool>

    private(set) var redeemSliderEnabled: Driver<Bool>!
    private(set) var redeemSliderText: Driver<String>!
    let selectedOutletId = Variable<Int?>(nil)

    // IBOutlet static
    let userNameStatic = Driver.of(NSLocalizedString("name", comment: ""))
    let quantityStatic = Driver.of(NSLocalizedString("purchase_detail_quantity_text", comment: ""))
    let cellHeight: Variable<CGFloat>

    init(
        userProvider: UserProvider = userProviderDefault
        , reservation: Reservation
        , redeemAPI: RedeemAPI = RedeemAPIDefault()
        , assetProvider: AssetProvider = assetProviderDefault
        , cellHeight: Variable<CGFloat>
        ) {
        self.cellHeight = cellHeight
        self.reservation = reservation
        self.userProvider = userProvider
        self.redeemAPI = redeemAPI
        self.assetProvider = assetProvider

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

        appImage = assetProvider.imageAssest.asDriver().map({ (imgAsset: ImageAssest) -> UIImage? in
            imgAsset.aboutImage
        })

        quantity = Driver.of("\(NSLocalizedString("receipt_detail_quantity_text", comment: "")): \(reservation.slotsReserved == 1 ? "1 \(NSLocalizedString("voucher", comment: ""))": "\(reservation.slotsReserved) \(NSLocalizedString("vouchers", comment: ""))")")

        redemtionDescription = Driver.of("\(NSLocalizedString("make_sure_only_you_swipe", comment: "")) \(reservation.listingDetails.company.name)")

        let receipt: String

        if let id = reservation.receiptId {
            receipt = id
        } else {
            receipt = "\(reservation.id)"
        }

        receiptID = Driver.of("\(NSLocalizedString("receipt_id", comment: "")): \(receipt.uppercaseString)")

        redeemCode = Driver.of(reservation.redemptionCode.uppercaseString)

        onlineRedeemDescription = Driver.of(reservation.listingDetails.redemptionInstructions)
        hiddenOnlineRedeemView = Driver.of(reservation.listingDetails.redemptionMethod != .voucherCode)

        super.init()

        if canRedeem(reservation) {
            redeemSliderText = Driver.of(NSLocalizedString("purchase_detail_swipe_to_redeem_text", comment: ""))
        } else {
            redeemSliderText = Driver.of(NSLocalizedString("cant_redeem_yet", comment: ""))
        }

        redeemSliderEnabled = Driver.of(canRedeem(reservation))

    }

    func didTapHowToRedeemButton() {
        let vc = HowToRedeemViewController.build(HowToRedeemViewControllerViewModel())
        let nvc = UINavigationController(rootViewController: vc)
        lightHouseService.navigate.onNext { (viewController) in
            viewController.presentViewController(nvc, animated: true, completion: nil)
        }
    }

    private func canRedeem(reservation: Reservation) -> Bool {
        let dateNow = NSDate()

        if reservation.listingDetails.option == .OpenVoucher {
            let redemptionEndTime = reservation.reservationToDateTime
            return dateNow.earlierThanDate(redemptionEndTime)
        } else if reservation.listingDetails.option == .TimeSlot {
            let redemptionBeginTime = reservation.reservationFromDateTime.dateByAddingTimeInterval(-30 * 60)
            let redemptionEndTime = reservation.reservationToDateTime
            return dateNow.laterThanDate(redemptionBeginTime) && dateNow.earlierThanDate(redemptionEndTime)
        } else {
            return false
        }
    }

    func requestRedeem() {
        let redeemAPIRequestPayload = RedeemAPIRequestPayload(redemptionIntent: [(code: reservation.redemptionCode, currentDateTime: NSDate(), outletId: selectedOutletId.value)])
        _ = redeemAPI.redeem(withRequestPayload: redeemAPIRequestPayload)
            .trackActivity(app.activityIndicator)
            .subscribe(
                onNext: { [weak self] (redeemAPIResponsePayload: RedeemAPIResponsePayload) in
                    guard let strongSelf = self else { return }
                    let redemption = redeemAPIResponsePayload.redemptions.first!
                    if redemption.success {
                        strongSelf.reservation.redeemedAt = NSDate()
                        strongSelf.reservation.reservationState = .Redeemed
                        strongSelf.redeemedReservation.onNext(strongSelf.reservation)
                        strongSelf.trackRedeemSuccess()
                    } else {
                        if let errorMessage = redemption.errorMessage {
                            UIAlertController.alertController(forTitle: "Fave", message: errorMessage)
                        }
                    }
                }, onError: { [weak self] (error: ErrorType) in
                    self?.lightHouseService.navigate.onNext({ (viewController) in
                        let alertController = UIAlertController.alertController(forError: error, actions: nil)
                        viewController.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
        ).addDisposableTo(disposeBag)
    }

    func trackRedeemTapped() {
        let analyticsModel = RedeemAnalyticsModel(reservation: self.reservation)
        analyticsModel.redeemButtonClickedEvent.sendToMoEngage()
    }

    func trackRedeemSuccess() {
        let analyticsModel = RedeemAnalyticsModel(reservation: reservation)
        analyticsModel.redeemSuccessful.sendToMoEngage()
    }
}
