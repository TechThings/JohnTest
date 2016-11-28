//
//  ListingsCollectionViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 14/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ListingsCollectionType: Int {
    case CurrentCollection = 0
    case Listing
    case CarouselCollections
}

final class ListingsCollectionItem {
    let itemType: ListingsCollectionType
    let item: Any

    init(itemType: ListingsCollectionType, item: AnyObject) {
        self.item = item
        self.itemType = itemType
    }
}

/**
 *  @author Nazih Shoura
 *
 *  ListingCollectionViewControllerViewModel
 */
final class ListingsCollectionViewControllerViewModel: ViewModel {

    // MARK- Dependancy
    let listingsAPI: ListingsAPI
    let locationService: LocationService
    let listingsCollectionsAPI: ListingsCollectionsAPI

    // MARK- Input
    let collectionId: Int

    // MARK- Output
    let listings = Variable([ListingType]())
    var currentCollection = Variable<ListingsCollection?>(nil)
    let carouselCollections = Variable([ListingsCollection]())
    let collectionItems: Driver<[ListingsCollectionItem]>

    init(
        collectionId: Int
        , listingsAPI: ListingsAPI = ListingsAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , listingsCollectionsAPI: ListingsCollectionsAPI = ListingsCollectionsAPIDefault()
        ) {
        self.collectionId = collectionId
        self.listingsAPI = listingsAPI
        self.locationService = locationService
        self.listingsCollectionsAPI = listingsCollectionsAPI

        collectionItems = Observable
            .combineLatest(
                currentCollection.asObservable()
                , listings.asObservable()
                , carouselCollections.asObservable()
                , resultSelector: { (currentCollection: ListingsCollection?, listings: [ListingType], carouselCollections: [ListingsCollection]) -> [ListingsCollectionItem] in

                var collectionItems = [ListingsCollectionItem]()

                if let currentCollection = currentCollection {
                    let currentCollectionItem = ListingsCollectionItem(itemType: .CurrentCollection, item:currentCollection)
                    collectionItems.append(currentCollectionItem)
                }

                    let listingItems = listings.map { (listing: ListingType) -> ListingsCollectionItem in
                        return ListingsCollectionItem(itemType: .Listing, item: listing)
                    }
                collectionItems += listingItems

                if carouselCollections.count > 0 {
                    let carouselCollectionsItem = ListingsCollectionItem(itemType: .CarouselCollections, item: carouselCollections)
                    collectionItems.append(carouselCollectionsItem)
                }
                return collectionItems

            }).asDriver(onErrorJustReturn: [ListingsCollectionItem]())

        super.init()
    }

    func requestListingsCollectionListings() {
        let listingsAPIRequestPayload = ListingsAPIRequestPayload(page: 1, limit: 100, order: nil, location: locationService.currentLocation.value, featured: nil, categoryIds: nil, collectionIds: [collectionId], categoryType: nil, listingTypes: nil, favorited_outlet: nil, outletIds: nil, priceRanges: nil, distances: nil)

        let _ = listingsAPI
            .getListings(withRequestPayload: listingsAPIRequestPayload)
            .trackActivity(app.activityIndicator)
            .subscribe(
                onNext: { [weak self] (listingsAPIResponsePayload: ListingsAPIResponsePayload) in
                    self?.listings.value = listingsAPIResponsePayload.listings
                }, onError: { [weak self] (error: ErrorType) in
                    self?.lightHouseService.navigate.onNext({ (viewController) in
                        let alertController = UIAlertController.alertController(forError: error)
                        viewController.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
            ).addDisposableTo(disposeBag)
    }

    func requestListingsCollections() {
        let response = listingsCollectionsAPI
            .listingsCollections(withRequestPayload: ListingsCollectionsAPIRequestPayload())

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError({ [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)}
                })
            .subscribeNext { [weak self]  (listingsCollectionsAPIResponsePayload: ListingsCollectionsAPIResponsePayload) in

                self?.currentCollection.value = listingsCollectionsAPIResponsePayload.listingsCollections
                    .filter {
                        (listingsCollection: ListingsCollection) -> Bool in listingsCollection.id == self?.collectionId
                    }.first

                self?.carouselCollections.value = listingsCollectionsAPIResponsePayload.listingsCollections
                    .filter {
                        (listingsCollection: ListingsCollection) -> Bool in listingsCollection.id != self?.collectionId
                }

            }
            .addDisposableTo(disposeBag)

    }
}

extension ListingsCollectionViewControllerViewModel: Refreshable {
    func refresh() {
        requestListingsCollectionListings()
        requestListingsCollections()
    }
}
