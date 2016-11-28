//
//  MultipleOutletsAPI.swift
//  FAVE
//
//  Created by Syahmi Ismail on 17/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CoreLocation

struct MultipleOutletsAPIRequestPayload {
    let page: Int?
    let limit: Int?
    let location: CLLocation?
    let listingId: Int

    init(
        page: Int?
        , limit: Int?
        , location: CLLocation?
        , listingId: Int
        ) {
        self.page = page
        self.limit = limit
        self.location = location
        self.listingId = listingId
    }
}

extension MultipleOutletsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["page"] = page
        parameters["limit"] = limit
        parameters["location"] = location

        return parameters
    }
}

protocol MultipleOutletsAPI {
    func getMultipleOutlets(withRequestPayload requestPayload: MultipleOutletsAPIRequestPayload) -> Observable<MultipleOutletsAPIResponsePayload>
}

final class MultipleOutletsAPIDefault: MultipleOutletsAPI {

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

    func getMultipleOutlets(withRequestPayload requestPayload: MultipleOutletsAPIRequestPayload) -> Observable<MultipleOutletsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/listings/\(requestPayload.listingId)/outlets")

        let result = Observable.create {
            (observer: AnyObserver<MultipleOutletsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL!, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<MultipleOutletsAPIResponsePayload, NSError>) -> Void in
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
}

struct MultipleOutletsAPIResponsePayload {
    let outlets: [Outlet]

    init(outlets: [Outlet]) {
        self.outlets = outlets
    }
}

extension MultipleOutletsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> MultipleOutletsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let multipleOutlets = json["outlets"] as? [AnyObject] else {return nil}

        var outlets = [Outlet]()
        for value in multipleOutlets {
            if let outlet = Outlet.serialize(value) {
                outlets.append(outlet)
            }
        }

        let result = MultipleOutletsAPIResponsePayload(outlets: outlets)
        return result
    }
}
