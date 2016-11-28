//
//  HomeOffersCarouselTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  HomeOffersCarouselTableViewCellViewModel
 */
final class HomeOffersCarouselTableViewCellViewModel: ViewModel {

    // MARK:- Dependency
    private let locationService: LocationService
    private let listingsAPI: ListingsAPI

    private var parameters: [String: AnyObject]

    // MARK- Output
    let sectionModel: Driver<HomeSection?>
    let listings = Variable<[ListingType]?>(nil)
    let activityIndicatorHidden = Variable(false)

    init(
        sectionModel: HomeSection,
        locationService: LocationService = locationServiceDefault,
        listingsAPI: ListingsAPI = ListingsAPIDefault()
        ) {
        self.parameters = sectionModel.parameters
        self.locationService = locationService
        self.sectionModel = Driver.of(sectionModel)
        self.listingsAPI = listingsAPI

        super.init()

        if let location = locationService.currentLocation.value {
            let latitudeString = String(location.coordinate.latitude)
            let longitudeString = String(location.coordinate.longitude)
            self.parameters["latitude"] = latitudeString
            self.parameters["longitude"] = longitudeString
        }
    }

    func didSelectItemAtIndex(index: Int) {
        if let listingsModel = listings.value {
            let listing = listingsModel[index]
            let vm = ListingViewModel(listingId: listing.id, outletId: listing.outlet.id, functionality: Variable(ListingViewModelFunctionality.Initiate()))
            let vc = ListingViewController.build(vm)

            lightHouseService
            .navigate
            .onNext({ (viewController) in
                viewController.navigationController?.pushViewController(vc, animated: true)
            })

            trackListingTapped(listing)
        }
    }

    func trackListingTapped(listing: ListingType) {
        let analyticsModel = HomeAnalyticsModel(listing: listing)
        analyticsModel.activityClicked.sendToMoEngage()
    }

    func requestData() -> Observable<ResponsePayload> {
        let response = listingsAPI.getListingsFromDict(parameters: parameters)

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError { [weak self] (error: ErrorType) in
                self?.listings.value = [ListingType]()
                self?.activityIndicatorHidden.value = true
            }
            .subscribeNext { [weak self]  (listingsAPIResponsePayload: ListingsAPIResponsePayload) in
                self?.listings.value = listingsAPIResponsePayload.listings
                self?.activityIndicatorHidden.value = true
            }
            .addDisposableTo(disposeBag)

        let result = response
            .map { (listingsAPIResponsePayload: ListingsAPIResponsePayload) -> ResponsePayload in
                return listingsAPIResponsePayload as ResponsePayload
        }

        return result
    }

}

// MARK:- Refreshable
extension HomeOffersCarouselTableViewCellViewModel: Refreshable {
    func refresh() {
        self.activityIndicatorHidden.value = false
        requestData()
    }
}
