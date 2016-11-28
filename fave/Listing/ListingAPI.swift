//
//  ListingAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CoreLocation

struct ListingAPIRequestPayload {
    let listingId: Int
    let outletId: Int?
    let location: CLLocation?

    init(listingId: Int
        , outletId: Int?
        , location: CLLocation?
        ) {
        self.listingId = listingId
        self.outletId = outletId
        self.location = location
    }
}

extension ListingAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["outlet_id"] = outletId

        if let location = location {
            parameters["latitude"] = location.coordinate.latitude
            parameters["longitude"] = location.coordinate.longitude
        }

        return parameters
    }
}

protocol ListingAPI {
    func listing(withRequestPayload requestPayload: ListingAPIRequestPayload) -> Observable<ListingAPIResponsePayload>
}

final class ListingAPIDefault: ListingAPI {

    private let apiService: APIService
    private let networkService: NetworkService
    private let cityProvider: CityProvider

    init(apiService: APIService = apiServiceDefault
        , networkService: NetworkService = networkServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        ) {
        self.apiService = apiService
        self.networkService = networkService
        self.cityProvider = cityProvider
    }

    func listing(withRequestPayload requestPayload: ListingAPIRequestPayload) -> Observable<ListingAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v2/cities/\(citySlug)/listings/\(requestPayload.listingId)")!

        let result = Observable.create {
            (observer: AnyObserver<ListingAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<ListingAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct ListingAPIResponsePayload {
    let listingDetails: ListingDetailsType
    init(listingDetails: ListingDetailsType) {
        self.listingDetails = listingDetails
    }
}

extension ListingAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ListingAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }
        guard let listingJson = json["listing"] as? [String: AnyObject] else { return nil}

        // Properties to initialize (copy from the object being serilized)
        var listingDetails: ListingDetailsType?

        // Properties initialization

        if let listingType = listingJson["listing_type"] as? String {
            if listingType == ListingOption.OpenVoucher.rawValue {
                listingDetails = ListingOpenVoucherDetails.serialize(listingJson)
            }
            if listingType == ListingOption.TimeSlot.rawValue {
                listingDetails = ListingTimeSlotDetails.serialize(listingJson)
            }
        }

        // Verify properties and initialize object
        if let listingDetails = listingDetails {
            let result = ListingAPIResponsePayload(listingDetails: listingDetails)
            return result
        }
        return nil
    }
}
