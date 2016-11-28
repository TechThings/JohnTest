//
//  OutletViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum OutletItemKind {
    case Header
    case Location
    case Separator
    case LocationHeader
    case OffersHeader
    case TimeslotListing
    case VoucherListing
}

final class OutletItem {
    let itemType: OutletItemKind
    let item: AnyObject?

    init(itemType: OutletItemKind, item: AnyObject?) {
        self.item = item
        self.itemType = itemType
    }
}

/**
 *  @author Nazih Shoura
 *
 *  OutletViewControllerViewModel
 */

final class OutletViewControllerViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    let outletId: Int
    let companyId: Int

    var outlet: Outlet?
    var company: Company?

    private let listingsAPI: ListingsAPI
    private let companyAPI: CompanyAPI
    private let locationService: LocationService

    // MARK- Output
    let outletItems = Variable<[Int:[OutletItem]]>([Int:[OutletItem]]())
    var outletItemsDict = [Int: [OutletItem]]()

    init(outletId: Int,
         companyId: Int,
         listingsAPI: ListingsAPI = ListingsAPIDefault(),
         companyAPI: CompanyAPI = CompanyAPIDefault(),
         locationService: LocationService = LocationServiceDefault()
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen

        self.outletId = outletId
        self.companyId = companyId

        self.listingsAPI = listingsAPI
        self.locationService = locationService
        self.companyAPI = companyAPI

        super.init()

        // Start Fetching Offers
        self.getCompany()
        self.fetchListings()
    }

    func getCompany() {
        let requestPayload = CompanyAPIRequestPayload(companyId: companyId)
        _ = companyAPI.getCompany(withRequestPayload: requestPayload)
            .trackActivity(app.activityIndicator)
            .asObservable()
            .subscribeNext({ [weak self] in
                self?.company = $0.company
                self?.outlet = $0.company.outlets?.filter({$0.id == self?.outletId}).first

                self?.outletItemsDict[0] = [OutletItem(itemType: .Header, item: nil)]
                if let type = self?.company?.companyType where type != .online {
                    self?.outletItemsDict[0]?.append(OutletItem(itemType: .Separator, item: nil))
                    self?.outletItemsDict[0]?.append(OutletItem(itemType: .LocationHeader, item: nil))
                    self?.outletItemsDict[0]?.append(OutletItem(itemType: .Location, item: nil))
                }
                self?.outletItems.value = (self?.outletItemsDict)!

                }).addDisposableTo(disposeBag)
    }

    func fetchListings() {
        let requestPayload = ListingsAPIRequestPayload(page: 1, limit: 100, order: nil, location: locationService.currentLocation.value, featured: nil, categoryIds: nil, collectionIds: nil, categoryType: nil, listingTypes: nil, favorited_outlet: nil, outletIds: [self.outletId], priceRanges: nil, distances: nil)

        listingsAPI.getListings(withRequestPayload: requestPayload)
            .trackActivity(app.activityIndicator)
            .flatMap {
                return $0.listings.toObservable()
            }
            .map {
                (listing) -> OutletItem in
                let listingType = { _ -> OutletItemKind in
                    if let _ = listing as? ListingTimeSlot {
                        return .TimeslotListing
                    } else {
                        return .VoucherListing
                    }
                }()
                let item = OutletItem(itemType: listingType, item: OutletOfferViewModel(listing: listing))
                return item
            }
            .toArray()
            .filterEmpty()
            .subscribeNext {
                [weak self] (items: [OutletItem]) in
                guard let strongself = self else {
                    return
                }
                var mutableItems = items
                mutableItems.insert(OutletItem(itemType: .Separator, item: nil), atIndex: 0)
                mutableItems.insert(OutletItem(itemType: .OffersHeader, item: nil), atIndex: 1)
                strongself.outletItemsDict[1] = mutableItems
                strongself.outletItems.value = strongself.outletItemsDict
            }
            .addDisposableTo(disposeBag)
    }

    // MARK:- Life cycle
    deinit {

    }
}
