//
//  ListingsAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 9/21/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CoreLocation

struct ListingsAPIRequestPayload {
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

extension ListingsAPIRequestPayload: Deserializable {

    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["page"]  = page
        parameters["limit"] = limit
        parameters["order"] = order?.APIString
        parameters["latitude"] = location?.coordinate.latitude
        parameters["longitude"] = location?.coordinate.longitude
        parameters["featured"] = featured
        parameters["category_ids"] = categoryIds?.map({ (categoryId: Int) -> String in "\(categoryId)"}).joinWithSeparator(",")
        parameters["collection_ids"] = collectionIds?.map({ (collectionId: Int) -> String in "\(collectionId)"}).joinWithSeparator(",")
        parameters["category_type"] = categoryType
        parameters["listing_types"] = listingTypes?.joinWithSeparator(",")
        parameters["favorited_outlet"] = favorited_outlet
        parameters["outlet_ids"] = outletIds?.map({ (outletId: Int) -> String in "\(outletId)"}).joinWithSeparator(",")
        parameters["price_ranges"] = priceRanges
        parameters["distances"] = distances

        return parameters
    }
}

protocol ListingsAPI {
    func getListings(withRequestPayload requestPayload: ListingsAPIRequestPayload) -> Observable<ListingsAPIResponsePayload>
    func getListingsFromDict(parameters parameters: [String: AnyObject]?) -> Observable<ListingsAPIResponsePayload>
}

final class ListingsAPIDefault: ListingsAPI {

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

    func getListingsFromDict(parameters parameters: [String : AnyObject]?) -> Observable<ListingsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v2/cities/\(citySlug)/listings")

        let result = Observable.create {
            (observer: AnyObserver<ListingsAPIResponsePayload>) -> Disposable in

            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL!, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<ListingsAPIResponsePayload, NSError>) -> Void in
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

    func getListings(withRequestPayload requestPayload: ListingsAPIRequestPayload) -> Observable<ListingsAPIResponsePayload> {

        let parameters = requestPayload.deserialize()
        return getListingsFromDict(parameters: parameters)
    }
}

struct ListingsAPIResponsePayload: ResponsePayload {
    let listings: [ListingType]
    let results: Int

    init(
        listings: [ListingType]
        , results: Int
        ) {
        self.listings = listings
        self.results = results
    }
}

extension ListingsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ListingsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize
        var listings = [ListingType]()

        // Properties initialization
        if let value = json["listings"] as? [AnyObject] {
            for representation in value {
                if let listingType = representation["listing_type"] as? String {
                    if listingType == ListingOption.OpenVoucher.rawValue {
                        if let listing = ListingOpenVoucher.serialize(representation) {
                            listings.append(listing)
                        }
                    }
                    if listingType == ListingOption.TimeSlot.rawValue {
                        if let listing = ListingTimeSlot.serialize(representation) {
                            listings.append(listing)
                        }
                    }
                }
            }
        }

        guard let results = json["meta"]?["results"] as? Int else { return nil }

        // Verify properties and initialize object
        let result = ListingsAPIResponsePayload(listings: listings, results: results)
        return result
    }
}
