//
//  CancelReservationViewModel.swift
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
 *  CancelReservationViewModel
 */
final class CancelReservationViewModel: ViewModel {

    // MARK:- Input
    let reservation: Reservation
    let cancelButtonDidTap = PublishSubject<Void>()
    let wireframeService: WireframeService
    let cancelReservationAPI: CancelReservationAPI

    // MARK- Output
    let canceledReservation = PublishSubject<Reservation>()

    // Static
    let cancelButtonText: Driver<String> = Driver.of(NSLocalizedString("purchase_detail_cancel_button_text", comment: ""))
    let cancelLabel: Driver<String>
    // Variable
    let cancelButtonEnabled: Driver<Bool>

    init(
        reservation: Reservation
        , cancelReservationAPI: CancelReservationAPI = CancelReservationAPIDefault()
        , wireframeService: WireframeService = wireframeServiceDefault
        ) {
        self.reservation = reservation
        self.cancelButtonEnabled = Driver.of(true)
        self.cancelReservationAPI = cancelReservationAPI
        self.wireframeService = wireframeService

        if let cancellationDeadlineDate = reservation.cancelationDeadlineDate?.RefundEndDateString {

            let cancellationPolicyText = "\(NSLocalizedString("receive_full_refund_in_fave_credit", comment: "")) \(cancellationDeadlineDate)"
            self.cancelLabel = Driver.of(cancellationPolicyText)
        } else {
            self.cancelLabel = Driver.of("")
        }

        super.init()

        cancelButtonDidTap.subscribeNext { [weak self] _ in

            self?.trackCancelTap()
            let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "Yes", style: .Default) { [weak self] _ in
                self?.requestCancelReservation()
            }
            self?.wireframeService.alertFor(title: NSLocalizedString("want_to_cancel_purchase", comment: ""), message: NSLocalizedString("received_refund_in_fave_credits", comment: ""), preferredStyle: .Alert, actions: [cancelAction, confirmAction])
            }.addDisposableTo(disposeBag)

    }

    private func trackCancelTap() {
        let analyticsModel = RedeemAnalyticsModel(reservation: self.reservation)
        analyticsModel.cancelReservationClicked.sendToMoEngage()
    }

    private func requestCancelReservation() {
        let cancelReservationAPIRequestPayload = CancelReservationAPIRequestPayload(reservationId: reservation.id)
        _ = cancelReservationAPI
            .cancelReservation(withRequestPayload: cancelReservationAPIRequestPayload)
            .subscribe (
                onNext: { [weak self] (cancelReservationAPIResponsePayload) in
                    self?.canceledReservation.onNext(cancelReservationAPIResponsePayload.reservation)
                    self?.trackReservationCancelled()
            }, onError: { [weak self] (error) in
                self?.lightHouseService.navigate.onNext { (viewController) in
                    let alertController = UIAlertController.alertController(forError: error)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        ).addDisposableTo(disposeBag)
    }

    private func trackReservationCancelled() {
        let analyticsModel = RedeemAnalyticsModel(reservation: self.reservation)
        analyticsModel.reservationCancelled.sendToMoEngage()
    }

}
