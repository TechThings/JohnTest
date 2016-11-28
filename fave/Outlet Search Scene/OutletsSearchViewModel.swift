//
//  OutletsSearchViewModel.swift
//  KFIT
//
//  Created by Nazih Shoura on 13/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

struct OutletsSearchViewModelState {
    let query: String
    let outletOrder: OutletsOrder
    let page: Int
    let loadedEverything: Bool

    init (query: String, outletOrder: OutletsOrder, page: Int, loadedEverything: Bool) {
        self.loadedEverything = loadedEverything
        self.page = page
        self.query = query
        self.outletOrder = outletOrder
    }
}

final class OutletsSearchViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependencies
    private let outletsSearchAPI: OutletsSearchAPI
    private let GGMapsSearchAPI: OutletsGGMapsSearchAPI
    private let wireframeService: WireframeService
    private let locationService: LocationService

    // MARK- Output
    let switchMapActiveImage = UIImage(named: "ic_toggle_list")
    let switchTableActiveImage = UIImage(named: "ic_toggle_map")
    let switchMapActiveText = NSLocalizedString("view_in_list", comment: "")
    let switchTableActiveText = NSLocalizedString("view_in_map", comment: "")
    let searchBarTextFieldPlaceholder = Variable("")
    let outlets = Variable([Outlet]())
    let isEmptyOutletsSearch = Variable(false)
    let outletsGGMapsSearch = Variable([OutletGGMapsSearch]())

    // MARK:- Constants
    let outletsPerPage      = 15

    // MARK:- State
    var viewModelState = Variable(OutletsSearchViewModelState(query: "", outletOrder: .ByDistance, page: 1, loadedEverything: false))

    func getGGMapsOutletsInfomation() -> String {
        let message = outletsGGMapsSearch.value.count > 0 ?

            "\(NSLocalizedString("no_results_found_for", comment: "")) \"\(viewModelState.value.query)\"\n\(NSLocalizedString("add_place_to_fave", comment: ""))" :
            "\(NSLocalizedString("no_results_found_for", comment: "")) \"\(viewModelState.value.query)\""
        return message
    }

    init(
        outletsSearchAPI: OutletsSearchAPI = OutletsSearchAPIDefault()
        , GGMapsSearchAPI: OutletsGGMapsSearchAPI = OutletsGGMapSearchAPIDefault()
        , wireframeService: WireframeService = wireframeServiceDefault
        , locationService: LocationService = locationServiceDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.outletsSearchAPI = outletsSearchAPI
        self.GGMapsSearchAPI = GGMapsSearchAPI
        self.locationService = locationService
        self.wireframeService = wireframeService
        super.init()

        self.searchBarTextFieldPlaceholder.value = NSLocalizedString("search_favorite_place", comment:"")
    }

    /**
     Search for outletsSearch matching the passed query ordered by the passed outletSearch order
     
     - parameter query:   The query to search for
     - parameter orderBy: The order that the outletsSearch should be sorted by
     */
    func searchOutletsForQuery(query: String, outletOrder: OutletsOrder) {

        // Clear out the previous search results
        outlets.value = [Outlet]()
        outletsGGMapsSearch.value = [OutletGGMapsSearch]()

        // Update view model state
        updateViewModelStateWithQuery(query, outletOrder: outletOrder, page: 1, loadedEverything: false)

            let outletsSearchRequestPayload = constructOutletsSearchRequestPayload()
            searchOutlets(requestPayload: outletsSearchRequestPayload)
    }

    /**
     Load the next page of results of the previously performed search
     */
    func loadNextPage() {

        // Don't hit the API if we have loaded everything
        if viewModelState.value.loadedEverything {
            return
        }

        // Update view model state
        updateViewModelStateWithQuery(viewModelState.value.query, outletOrder: viewModelState.value.outletOrder, page: viewModelState.value.page + 1, loadedEverything: viewModelState.value.loadedEverything)

            let outletsSearchRequestPayload = constructOutletsSearchRequestPayload()
            searchOutlets(requestPayload: outletsSearchRequestPayload)
    }

    func loadGGMapsOutlet() {
            let outletsSearchRequestPayload = constructOutletsGGMapsSearchRequestPayload()
            searchGGMapsOutlets(requestPayload: outletsSearchRequestPayload)
    }

    // MARK:- Helper functions
    /**
     Construct an OutletsRequestPayload using the current view model state
     
     - returns: The constructed OutletRequestPayload
     */
    private func constructOutletsSearchRequestPayload() -> OutletsSearchRequestPayload {

        var latitudeString: String? = nil
        var longitudeString: String? = nil

        if let location = locationService.currentLocation.value {
            latitudeString = String(location.coordinate.latitude)
            longitudeString = String(location.coordinate.longitude)
        }

        let outletsSearchRequestPayload = OutletsSearchRequestPayload(
            query: viewModelState.value.query
            , orderBy: viewModelState.value.outletOrder.APIString
            , latitude: latitudeString
            , longitude: longitudeString
            , page: viewModelState.value.page
            , outletsPerPage: outletsPerPage
            , radius: nil
            , excludeFavorited: false
        )

        return outletsSearchRequestPayload
    }

    private func constructOutletsGGMapsSearchRequestPayload() -> OutletGGMapsSearchRequestPayload {
        // TAG: Cheah, what is the default parameters for the location for google places?
        var latitude: Double!
        var longitude: Double!

        if let location = locationService.currentLocation.value {
            latitude = (location.coordinate.latitude)
            longitude = (location.coordinate.longitude)
        }

        let requestPayload = OutletGGMapsSearchRequestPayload (googleAPIKey: app.keys.GoogleAPI,lat: latitude, long: longitude, query: viewModelState.value.query)
        return requestPayload
    }

    private func searchGGMapsOutlets(requestPayload requestPayload: OutletGGMapsSearchRequestPayload) {
        _ = GGMapsSearchAPI
            .searchGGMapsOutlet(requestPayload: requestPayload)
            .trackActivity(activityIndicator)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(
                onNext: { [weak self] (outletsSearchResponsePayload) in
                    if let strongSelf = self {
                        strongSelf.outletsGGMapsSearch.value.appendContentsOf(outletsSearchResponsePayload.outletsSearch)
                    }
                }, onError: { [weak self]  (error) in
                    self?.wireframeService.alertFor(error, actions: nil)
                }
        )
    }

    private func searchOutlets(requestPayload requestPayload: OutletsSearchRequestPayload) {
        _ = outletsSearchAPI
            .searchOutlets(requestPayload: requestPayload)
            .trackActivity(activityIndicator)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(
                onNext: { [weak self] (outletsSearchResponsePayload) in
                    if let strongSelf = self {
                        // Update view model state
                        strongSelf.updateViewModelStateWithQuery(strongSelf.viewModelState.value.query, outletOrder: strongSelf.viewModelState.value.outletOrder, page: strongSelf.viewModelState.value.page, loadedEverything: outletsSearchResponsePayload.outlets.isEmpty)

                        // Success procedure
                        strongSelf.outlets.value.appendContentsOf(outletsSearchResponsePayload.outlets)

                        strongSelf.isEmptyOutletsSearch.value = (strongSelf.outlets.value.count == 0)
                    }
                }, onError: { [weak self]  (error) in
                    self?.wireframeService.alertFor(error, actions: nil)
                }
        )
    }

    private func updateViewModelStateWithQuery(query: String, outletOrder: OutletsOrder, page: Int, loadedEverything: Bool) {
        viewModelState.value = OutletsSearchViewModelState(query: query, outletOrder: outletOrder, page: page, loadedEverything: loadedEverything)
    }
}

extension OutletsSearchViewModel: Refreshable {
    func refresh() {
        outlets.value = [Outlet]()
        searchOutletsForQuery(viewModelState.value.query, outletOrder: viewModelState.value.outletOrder)
    }
}
