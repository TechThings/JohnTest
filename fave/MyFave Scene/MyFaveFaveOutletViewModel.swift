//
//  MyFaveFaveOutletViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/7/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

/**
 *  @author Thanh KFit
 *
 *  MyFaveFaveOutletViewModel
 */
final class MyFaveFaveOutletViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency

    private let outletsSearchAPI: OutletsSearchAPI
    private let favoriteOutletsAPI: FavoriteOutletsAPI
    private let locationService: LocationService

    // MARK- Output
    let faveOutlets = Variable([Outlet]())
    let isEmptyFaveOutlet = Variable(false)
    let suggestionOutlets = Variable([Outlet]())
    var loadingFaveOutletDone = false

    init(
        favoriteOutletsAPI: FavoriteOutletsAPI = FavoriteOutletsAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , outletsSearchAPI: OutletsSearchAPI = OutletsSearchAPIDefault()
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.favoriteOutletsAPI = favoriteOutletsAPI
        self.locationService = locationService
        self.outletsSearchAPI = outletsSearchAPI
    }

    func loadFavoriteOutlets() {
        let requestPayload = FavoriteOutletsAPIRequestPayload(location: locationService.currentLocation.value)

        _ = favoriteOutletsAPI.favoriteOutlets(withRequestPayload: requestPayload).subscribe(
            onNext : { [weak self] in
                self?.faveOutlets.value = $0.outlets
                self?.isEmptyFaveOutlet.value = $0.outlets.count == 0
                self?.loadingFaveOutletDone = true
            }, onError: { [weak self] _ in
                self?.faveOutlets.value = []
                self?.isEmptyFaveOutlet.value = true
                self?.loadingFaveOutletDone = true
            }
        )
    }

    private func constructOutletsSearchRequestPayload() -> OutletsSearchRequestPayload {

        var latitudeString: String? = nil
        var longitudeString: String? = nil

        if let location = locationService.currentLocation.value {
            latitudeString = String(location.coordinate.latitude)
            longitudeString = String(location.coordinate.longitude)
        }
        let outletsSearchRequestPayload = OutletsSearchRequestPayload(
            query: ""
            , orderBy: OutletsOrder.ByFavorited.APIString
            , latitude: latitudeString
            , longitude: longitudeString
            , page: 1
            , outletsPerPage: 5
            , radius: nil
            , excludeFavorited: true
        )
        return outletsSearchRequestPayload
    }

    func loadSuggestionOutlets() {
        let outletSearchAPIRequestPayload = constructOutletsSearchRequestPayload()
        _ = outletsSearchAPI
            .searchOutlets(requestPayload: outletSearchAPIRequestPayload)
            .trackActivity(app.activityIndicator)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(
                onNext: { [weak self] in
                    self?.suggestionOutlets.value = $0.outlets
                }
        )
    }
}

// MARK:- Refreshable
extension MyFaveFaveOutletViewModel: Refreshable {
    func refresh() {
        loadFavoriteOutlets()
    }
}
