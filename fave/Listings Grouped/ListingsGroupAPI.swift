//
//  ListingsGroupAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 9/21/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CoreLocation

struct ListingsGroupAPIRequestPayload {
    let page: Int
    let limit: Int
    let order: ListingsOrder?
    let location: CLLocation?
    let featured: Bool?
    let categoryIds: [Int]?
    let collectionIds: [Int]?
    let categoryType: String?
    let listingTypes: [String]?
    let favorited_outlet: Bool?
    let outletIds: [Int]?
    let priceRanges: Int?
    let distances: Int?

    init(page: Int
        , limit: Int
        , order: ListingsOrder?
        , location: CLLocation?
        , featured: Bool? = nil
        , categoryIds: [Int]? = nil
        , collectionIds: [Int]? = nil
        , categoryType: String? = nil
        , listingTypes: [String]? = nil
        , favorited_outlet: Bool? = nil
        , outletIds: [Int]? = nil
        , priceRanges: Int? = nil
        , distances: Int? = nil
        ) {
        self.page = page
        self.limit = limit
        self.order = order
        self.location = location
        self.featured = featured
        self.categoryIds = categoryIds
        self.collectionIds = collectionIds
        self.categoryType = categoryType
        self.listingTypes = listingTypes
        self.favorited_outlet = favorited_outlet
        self.outletIds = outletIds
        self.priceRanges = priceRanges
        self.distances = distances
    }
}

extension ListingsGroupAPIRequestPayload: Deserializable {

    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["page"]  = page
        parameters["limit"] = limit

        if let order = order?.APIString {
            parameters["order"] = order
        }

        if let location = location {
            parameters["latitude"] = location.coordinate.latitude
            parameters["longitude"] = location.coordinate.longitude
        }

        if let featured = featured {
            parameters["featured"] = featured
        }

        if let categoryIds = categoryIds where categoryIds.count > 0 {
            parameters["category_ids"] = categoryIds.map({ (categoryId: Int) -> String in "\(categoryId)"}).joinWithSeparator(",")
        }

        if let collectionIds = collectionIds where collectionIds.count > 0 {
            parameters["collection_ids"] = collectionIds.map({ (collectionId: Int) -> String in "\(collectionId)"}).joinWithSeparator(",")
        }

        if let categoryType = categoryType {
            parameters["category_type"] = categoryType
        }

        if let listingTypes = listingTypes {
            parameters["listing_types"] = listingTypes.joinWithSeparator(",")
        }

        if let favorited_outlet = favorited_outlet {
            parameters["favorited_outlet"] = favorited_outlet
        }

        if let outletIds = outletIds where outletIds.count > 0 {
            parameters["outlet_ids"] = outletIds.map({ (outletId: Int) -> String in "\(outletId)"}).joinWithSeparator(",")
        }

        if let priceRanges = priceRanges {
            parameters["price_ranges"] = priceRanges
        }

        if let distances = distances {
            parameters["distances"] = distances
        }

        return parameters
    }
}

protocol ListingsGroupAPI {
    func getListings(withRequestPayload requestPayload: ListingsGroupAPIRequestPayload) -> Observable<ListingsGroupAPIResponsePayload>
    func getListingsFromDict(parameters parameters: [String: AnyObject]?) -> Observable<ListingsGroupAPIResponsePayload>
}

class ListingsGroupAPIDefault: ListingsGroupAPI {

    private let apiService: APIService
    private let networkService: NetworkService
    private let cityProvider: CityProvider
    private let app: AppType

    init(apiService: APIService = apiServiceDefault
        , networkService: NetworkService = networkServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        , app: AppType = appDefault
        ) {
        self.app = app
        self.apiService = apiService
        self.networkService = networkService
        self.cityProvider = cityProvider
    }

    func getListingsFromDict(parameters parameters: [String : AnyObject]?) -> Observable<ListingsGroupAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v2/cities/\(citySlug)/listings/groups")

        let result = Observable.create {
            (observer: AnyObserver<ListingsGroupAPIResponsePayload>) -> Disposable in

            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL!, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            // TAG: Logging
            #if DEBUG
                print("Requesting \(URLRequest.description)")
            #endif

            request.responseObject {
                (response: Response<ListingsGroupAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value {
                    observer.onNext(value)
                }
                if let error = response.result.error {
                    observer.onError(error)
                }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }

    func getListings(withRequestPayload requestPayload: ListingsGroupAPIRequestPayload) -> Observable<ListingsGroupAPIResponsePayload> {

        let parameters = requestPayload.deserialize()
        return getListingsFromDict(parameters: parameters)
    }
}

struct ListingsGroupAPIResponsePayload: ResponsePayload {
    let listings: [ListingsGroup]
    let results: Int

    init(
        listings: [ListingsGroup]
        , results: Int
        ) {
        self.listings = listings
        self.results = results
    }
}

extension ListingsGroupAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ListingsGroupAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize
        var listings = [ListingsGroup]()

        // Properties initialization
        if let value = json["listings"] as? [AnyObject] {
            for representation in value {
                if let listing = ListingsGroup.serialize(representation) {
                    listings.append(listing)
                }
            }
        }

        guard let results = json["meta"]?["results"] as? Int else {
            return nil
        }

        let result = ListingsGroupAPIResponsePayload(listings: listings, results: results)
        return result
    }
}
