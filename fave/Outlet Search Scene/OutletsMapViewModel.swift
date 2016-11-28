//
//  OutletsMapViewModel.swift
//  KFIT
//
//  Created by Nazih Shoura on 15/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa
import UIKit
import CoreLocation
import MapKit

private struct OutletsMapViewModelState {
    let page: Int
    let loadedEverything: Bool

    init (page: Int, loadedEverything: Bool) {
        self.loadedEverything = loadedEverything
        self.page = page
    }
}

final class OutletsMapViewModel: ViewModel {
    // FIXME: CC: Very big CC, out cashe behind the API layer
    static var outletsCache = [String: [Outlet]]()
    private let API: OutletsSearchAPI!
    private let wireframeService: WireframeService!
    private let locationService: LocationService!

    // Initial procedure
    let outletsFocusedCollectionToAdd = Variable([(outlet: Outlet, focused: Bool)]())
    let region: Variable<MKCoordinateRegion?> = Variable(nil)
    let resetMapTrigger: Variable<Void?> = Variable(nil)

    // MARK: Constants
    private let outletsPerPage = 25
    private let updateLocationTimeInterval: NSTimeInterval = 30 // Update every 30 seconds
    private let userResionDistance: Double = 5000
    private let cityResionDistance: Double = 20000

    let locationUpdateTimer = Observable<Int>.timer(0, period: 30, scheduler: MainScheduler.instance)

    // Initial State
    private var viewModelState = OutletsMapViewModelState(page: 1, loadedEverything: false)
    private let currentCenter: Variable<CLLocation?> = Variable(nil)

    let outletsToFocusOn = Variable([Outlet]())

    init(
        API: OutletsSearchAPI = OutletsSearchAPIDefault()
        , wireframeService: WireframeService = wireframeServiceDefault
        , locationService: LocationService = locationServiceDefault
        ) {
        self.API = API
        self.locationService = locationService
        self.wireframeService = wireframeService

        super.init()

        updateLocation()
        updateRegion()

    }

    private func updateLocation() {
        locationUpdateTimer
            .subscribeNext { [weak self] _ in
                self?.locationService.updateLocation()
            }.addDisposableTo(disposeBag)
    }

    func updateRegion() {

        if let userLocation = locationService.currentLocation.value {
            currentCenter.value = userLocation // Update the current center
            region.value = MKCoordinateRegionMakeWithDistance(currentCenter.value!.coordinate, userResionDistance, userResionDistance) // Update the region center
        } else { // If all failed then show an error

            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)
            let retryAction = UIAlertAction(title: NSLocalizedString("retry", comment: ""), style: .Default, handler: { [weak self] _ in self?.updateRegion()
                })

            wireframeService.alertFor(
                title: "Fave"
                , message: NSLocalizedString("couldnt_obtain_location", comment: "")
                , preferredStyle: .Alert
                , actions: [cancelAction, retryAction]
            )
        }
    }

    // MARK:- Helper functions
    /**
     Construct an OutletsRequestPayload using the current view model state
     
     - returns: The constructed OutletRequestPayload
     */
    private func constructOutletsRequestPayload() throws -> OutletsSearchRequestPayload {

        var latitudeString: String!
        var longitudeString: String!

        if let center = currentCenter.value {
            latitudeString = String(center.coordinate.latitude)
            longitudeString = String(center.coordinate.longitude)
        } else {
            latitudeString = ""
            longitudeString = ""
        }

        let outletsSearchRequestPayload = OutletsSearchRequestPayload(
            query: ""
            , orderBy: OutletsOrder.ByDistance.APIString
            , latitude: latitudeString
            , longitude: longitudeString
            , page: viewModelState.page
            , outletsPerPage: outletsPerPage
            , radius: 10
            , excludeFavorited: false
        )

        return outletsSearchRequestPayload
    }

    /**
     A recursive function that downloads the outletsSearch
     */
    private func updateOutletsWithRequestPayload(requestPayload: OutletsSearchRequestPayload) {
        // FIXME: Very big CC, out cashe behind the API layer
//        if let outletsSearch = OutletsMapViewModel.outletsCashe["\(requestPayload.page)\(requestPayload.city)"] {

        if let outletsSearch = OutletsMapViewModel.outletsCache["\(requestPayload.page)"] {

            // Success procedure
            self.outletsFocusedCollectionToAdd.value = outletsSearch
                .map { ($0, self.outletsToFocusOn.value.contains($0)) }

            // Update view model state
            self.updateViewModelStatePage(self.viewModelState.page + 1, loadedEverything: false)

            // Update the outletsSearch to include the next page if we havn't loaded everything
            if (!self.viewModelState.loadedEverything) {
                do {
                    let outletsRequestPayload = try self.constructOutletsRequestPayload()
                    self.updateOutletsWithRequestPayload(outletsRequestPayload)
                } catch {
                    self.failed()
                }
            }
            return
        }

        _ = API
            .searchOutlets(requestPayload: requestPayload)
            .trackActivity(activityIndicator)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(
                onNext: { [weak self] (outletsSearchResponsePayload) in
                    // FIXME: Very big CC, out cashe behind the API layer
//                    OutletsMapViewModel.outletsCashe["\(requestPayload.page)\(requestPayload.city)"] = outletsSearchResponsePayload.outletsSearch
                    OutletsMapViewModel.outletsCache["\(requestPayload.page)"] = outletsSearchResponsePayload.outlets

                    if let strongSelf = self {
                    // Success procedure
                    strongSelf.outletsFocusedCollectionToAdd.value = outletsSearchResponsePayload
                        .outlets
                        .map { ($0, strongSelf.outletsToFocusOn.value.contains($0)) }

                    // Update view model state
                    strongSelf.updateViewModelStatePage(strongSelf.viewModelState.page + 1, loadedEverything: outletsSearchResponsePayload.outlets.isEmpty)

                    // Update the outletsSearch to include the next page if we havn't loaded everything
                    if (!strongSelf.viewModelState.loadedEverything) {
                        do {
                            let outletsRequestPayload = try strongSelf.constructOutletsRequestPayload()
                            strongSelf.updateOutletsWithRequestPayload(outletsRequestPayload)
                        } catch {
                            strongSelf.failed()
                        }
                    }
                    }
                }, onError: { [weak self] (error) in
                    self?.failed(error)
                }
        )
    }

    // Failuer procedure
    private func failed(error: ErrorType? = nil) {
        let okAction = UIAlertAction(title: NSLocalizedString("msg_dialog_ok", comment: ""), style: .Cancel, handler: nil)
        let errorDescription = NSLocalizedString("msg_something_wrong", comment:"")
        let errorString = "Fave"
        wireframeService.alertFor(title: errorString, message: errorDescription, preferredStyle: .Alert, actions: [okAction])
    }

    private func updateViewModelStatePage(page: Int, loadedEverything: Bool) {
        viewModelState = OutletsMapViewModelState(page: page, loadedEverything: loadedEverything)
    }
}

extension OutletsMapViewModel: Refreshable {
    func refresh() {
        outletsFocusedCollectionToAdd.value = [(outlet: Outlet, focused: Bool)]()
        updateViewModelStatePage(1, loadedEverything: false)
        resetMapTrigger.value = nil

        do {
            let outletsRequestPayload = try constructOutletsRequestPayload()
            updateOutletsWithRequestPayload(outletsRequestPayload)
        } catch {
            failed()
        }
    }
}
