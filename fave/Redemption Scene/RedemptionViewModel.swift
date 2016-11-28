//
//  RedemptionViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import Alexandria

enum RedemptionItemKind {
    case RedeemableReservationView
    case CancelReservationView
    case ListingOutletView
    case ReservationTimeSlotDetailsView
    case OutletContactView
    case ViewAllMultipleOutletsView
    case RedeemedReservationView
    case ThingsToKnow
    case CanceledReservationView
    case PendingPaymentReservationView
    case ProcessingPaymentReservationView
}

/**
 *  @author Nazih Shoura
 *
 *  RedemptionViewModel
 */
final class RedemptionViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen
    private let locationService: LocationService

    // MARK:- Dependency
    private let reservationInfoAPI: ReservationInfoAPI
    private let paymentService: PaymentService

    private let refreshWithReservation = PublishSubject<Reservation>()
    let activityThingsToKnowRowHeight  = Variable<CGFloat>(0)
    let redeemableReservationRowHeight = Variable<CGFloat>(UITableViewAutomaticDimension)

    // MARK:- Intermediate
    let reservation                    = Variable<Reservation?>(nil)
    let cancelReservation              = PublishSubject<Reservation>()
    let openOutlet                     = PublishSubject<(Outlet, Company)>()
    let reservationId: Int

    // MARK:- Multiple outlet trigger
    let redeemShowConfirm     = PublishSubject<()>()
    let redeemCancelDidTap    = PublishSubject<Void>()
    let redeemConfirmedDidTap = PublishSubject<Void>()
    let selectedOutletId      = Variable<Int?>(nil)

    // MARK- Output
    var redeemItemsKind = Variable([RedemptionItemKind]())

    init(
        reservationId: Int
        , reservationInfoAPI: ReservationInfoAPI = ReservationInfoAPIDefault()
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , locationService: LocationService = locationServiceDefault
        , paymentService: PaymentService = paymentServiceDefault
        ) {
        self.paymentService = paymentService
        self.trackingScreen = trackingScreen
        self.reservationId = reservationId
        self.reservationInfoAPI = reservationInfoAPI
        self.locationService = locationService

        super.init()

        refreshWithReservation.subscribeNext { [weak self] (reservation) in
            self?.reservation.value = reservation
            self?.refresh()
        }.addDisposableTo(disposeBag)

        cancelReservation.subscribeNext { [weak self] (reservation) in
            self?.reservation.value = reservation
            self?.refresh()
            }.addDisposableTo(disposeBag)

        reservation.asObservable()
            .filterNil()
            .subscribeNext { [weak self](reservation) in
            self?.updateCellViewModel()
        }.addDisposableTo(disposeBag)

        getReservationInfo()
        // why need call twice?
//        refresh()
    }

    func viewModel(forRedemptionItemKind redemptionItemKind: RedemptionItemKind) -> ViewModel? {
        if let reservation = reservation.value {
            switch redemptionItemKind {
            case .RedeemableReservationView:
                let redeemableReservationViewModel = RedeemableReservationViewModel(reservation: reservation, cellHeight: redeemableReservationRowHeight)

                redeemableReservationViewModel.redeemedReservation.bindTo(refreshWithReservation).addDisposableTo(disposeBag)

                redeemCancelDidTap.bindTo(redeemableReservationViewModel.redeemCancelRequest).addDisposableTo(disposeBag)
                redeemConfirmedDidTap.bindTo(redeemableReservationViewModel.redeemConfirmRequest).addDisposableTo(disposeBag)
                selectedOutletId.asObservable().bindTo(redeemableReservationViewModel.selectedOutletId).addDisposableTo(disposeBag)

                return redeemableReservationViewModel

            case .CancelReservationView:
                let cancelReservationViewModel = CancelReservationViewModel(reservation: reservation)
                cancelReservationViewModel.canceledReservation.bindTo(cancelReservation).addDisposableTo(disposeBag)
                return cancelReservationViewModel

            case .ListingOutletView:
                let listingOutletViewModel = ListingOutletViewModel(listing: reservation.listingDetails)
                listingOutletViewModel.openOutlet.bindTo(openOutlet).addDisposableTo(disposeBag)
                return listingOutletViewModel

            case .ReservationTimeSlotDetailsView:
                let reservationTimeSlotDetailsViewModel = ReservationTimeSlotDetailsViewModel(reservation: reservation)
                return reservationTimeSlotDetailsViewModel

            case .OutletContactView:
                let outletContactViewModel = OutletContactViewModel(outlet: reservation.listingDetails.outlet)
                return outletContactViewModel

            case .ViewAllMultipleOutletsView:
                let viewAllMultipleOutletsView = ViewAllMultipleOutletsViewModel(listing: reservation.listingDetails)
                return viewAllMultipleOutletsView

            case .RedeemedReservationView:
                let redeemedReservationViewModel = RedeemedReservationViewModel(reservation: reservation)
                return redeemedReservationViewModel

            case .ThingsToKnow:
                let ThingsToKnowViewCellViewModel = ListingThingsToKnowTableViewCellViewModel(listing: reservation.listingDetails, cellHeight: activityThingsToKnowRowHeight)
                return ThingsToKnowViewCellViewModel

            case .CanceledReservationView:
                let canceledReservationViewCellViewModel =
                    CanceledReservationViewCellViewModel(reservation: reservation)
                return canceledReservationViewCellViewModel // Doesn't need a viewModel

            case .PendingPaymentReservationView:
                let pendingPaymentReservationViewModel = PendingPaymentReservationViewModel(reservation: reservation)
                return pendingPaymentReservationViewModel

            case .ProcessingPaymentReservationView:
                let processingPaymentReservationViewModel = ProcessingPaymentReservationViewModel(reservation: reservation)
                return processingPaymentReservationViewModel
            }
        } else {
            return nil
        }
    }

    func getReservationInfo() {
        _ = reservationInfoAPI.getReservationInfo(withRequestPayload: ReservationInfoAPIRequestPayload(id: reservationId))
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
            .bindTo(reservation)
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension RedemptionViewModel: Refreshable {
    func refresh() {
        getReservationInfo()
    }

    func updateCellViewModel() {
        var allItems = [RedemptionItemKind]()
        if let reservation = reservation.value {
            switch reservation.reservationState {
            case .Confirmed:
                allItems.append(.RedeemableReservationView)
                allItems.append(.ListingOutletView)
                allItems.append(.ReservationTimeSlotDetailsView)
                if reservation.listingDetails.totalRedeemableOutlets > 1 {
                    allItems.append(.ViewAllMultipleOutletsView)
                } else {
                    allItems.append(.OutletContactView)
                }

            case .Cancelled, .ClassCancelled, .Expired:
                allItems.append(.CanceledReservationView)
                allItems.append(.ListingOutletView)
                allItems.append(.ReservationTimeSlotDetailsView)
                if reservation.listingDetails.totalRedeemableOutlets > 1 {
                    allItems.append(.ViewAllMultipleOutletsView)
                } else {
                    allItems.append(.OutletContactView)
                }

            case .Redeemed:
                allItems.append(.RedeemedReservationView)
                allItems.append(.ListingOutletView)
                allItems.append(.ReservationTimeSlotDetailsView)
                if reservation.listingDetails.totalRedeemableOutlets > 1 {
                    allItems.append(.ViewAllMultipleOutletsView)
                } else {
                    allItems.append(.OutletContactView)
                }

            case .PendingPayment:
                allItems.append(.PendingPaymentReservationView)
                allItems.append(.ListingOutletView)
                allItems.append(.ReservationTimeSlotDetailsView)
                if reservation.listingDetails.totalRedeemableOutlets > 1 {
                    allItems.append(.ViewAllMultipleOutletsView)
                } else {
                    allItems.append(.OutletContactView)
                }
            case .PaymentProcessing:
                allItems.append(.ProcessingPaymentReservationView)
                allItems.append(.ListingOutletView)
                allItems.append(.ReservationTimeSlotDetailsView)
                if reservation.listingDetails.totalRedeemableOutlets > 1 {
                    allItems.append(.ViewAllMultipleOutletsView)
                } else {
                    allItems.append(.OutletContactView)
                }
            }

            if let finePrint = reservation.listingDetails.finePrint where finePrint.isEmpty == false {
                allItems.append(.ThingsToKnow)
            }

            // Add Cancellation Button under certain conditions
            if (!reservation.isLateToCancel && reservation.reservationState != .Cancelled && reservation.reservationState != .ClassCancelled
                && reservation.reservationState != .Redeemed && reservation.cancellable) {
                allItems.append(.CancelReservationView)
            }

            redeemItemsKind.value = allItems
        }
    }
}
