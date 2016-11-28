//
//  ListingViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ListingViewModelFunctionality {
    case Initiate()
    case InitiateFromChat(channelListing: Variable<ListingType?> )
}

/**
 *  @author Nazih Shoura
 *
 *  ListingViewModel
 */
final class ListingViewModel: ViewModel, HasFunctionality {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    private let listingAPI: ListingAPI
    private let locationService: LocationService

    let rxAnalytics: RxAnalytics

    // MARK:- Input
    let listingId: Int
    let outletId: Int?
    let channelListing: Variable<ListingType?>
    let functionality: Variable<ListingViewModelFunctionality>

    // MARK- Output

    let listingDetails = Variable<ListingDetailsType?>(nil)
    var reviewsCount = 0
    var hasThingsToKnow = false
    var hasWhatYouGet = false
    var hasInfo = false
    let buyNowButtonEnabled: Driver<Bool>
    var hasCancellationPolicy: Bool = true
    var hasFavePromise: Bool = true
    var hasLocation: Bool = true

    init(
        listingAPI: ListingAPIDefault = ListingAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , listingId: Int
        , outletId: Int?
        , functionality: Variable<ListingViewModelFunctionality>
        , channelListing: Variable<ListingType?> = Variable(nil)
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , rxAnalytics: RxAnalytics       = rxAnalyticsDefault
        ) {
        self.trackingScreen = trackingScreen
        self.rxAnalytics    = rxAnalytics
        self.channelListing = channelListing
        self.listingAPI = listingAPI
        self.locationService = locationService
        self.listingId = listingId
        self.outletId = outletId
        self.functionality = functionality

        self.buyNowButtonEnabled = listingDetails.asDriver().map({ (listingDetails: ListingDetailsType?) -> Bool in
            if listingDetails is ListingOpenVoucher {
                let voucherListing = listingDetails as! ListingOpenVoucher
                if let voucherDetail = voucherListing.voucherDetail {
                    return voucherDetail.purchaseSlots > 0
                } else {
                    return false
                }
            } else if listingDetails is ListingTimeSlot {
                let timeslotListing = listingDetails as! ListingTimeSlot
                return timeslotListing.classSessions.isNotEmpty
            }

            return false
        })
    }

    var shouldHideBuyButton: Bool {
        switch self.functionality.value {
        case ListingViewModelFunctionality.Initiate():
            return false

        case ListingViewModelFunctionality.InitiateFromChat(channelListing: _):
            return true
        }
    }
}

// MARK:- Refreshable
extension ListingViewModel: Refreshable {
    func refresh() {
        let listingAPIRequestPayload = ListingAPIRequestPayload(listingId: listingId, outletId: outletId, location: locationService.currentLocation.value)

        _ = listingAPI
            .listing(withRequestPayload: listingAPIRequestPayload)
            .trackActivity(app.activityIndicator)
            .trackActivity(activityIndicator)
            .subscribe(
                onNext: { [weak self] (listingAPIResponsePayload) in
                    if let finePrint = listingAPIResponsePayload.listingDetails.finePrint where finePrint.isEmpty == false {
                        self?.hasThingsToKnow = true
                    } else {
                        self?.hasThingsToKnow = false
                    }
                    if let whatYouGet = listingAPIResponsePayload.listingDetails.whatYouGet where whatYouGet.isEmpty == false {
                        self?.hasWhatYouGet = true
                    } else {
                        self?.hasWhatYouGet = false
                    }
                    self?.hasInfo = !(listingAPIResponsePayload.listingDetails.tips.emptyOnNil()).isEmpty
                    if let reviews = listingAPIResponsePayload.listingDetails.company.reviews {
                        self?.reviewsCount = reviews.count
                    }

                    if let favePromise = listingAPIResponsePayload.listingDetails.showFavePromise {
                        self?.hasFavePromise = favePromise
                    }
                    if let cancellation = listingAPIResponsePayload.listingDetails.showCancellationPolicy {
                    self?.hasCancellationPolicy = cancellation
                    }

                    self?.listingDetails.value = listingAPIResponsePayload.listingDetails
                }, onError: { [weak self] (error) in
                    self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                        viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                    }
                }
            ).addDisposableTo(disposeBag)
    }
}
