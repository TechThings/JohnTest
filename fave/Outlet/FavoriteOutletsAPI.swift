//
//  FavoriteOutletsAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CoreLocation

struct FavoriteOutletsAPIRequestPayload {
    let location: CLLocation?

    init(
        location: CLLocation?
        ) {
        self.location = location
    }
}

extension FavoriteOutletsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        if let location = location {
        parameters["latitude"] = location.coordinate.latitude
        parameters["longitude"] = location.coordinate.longitude
        }

        return parameters
    }
}

protocol FavoriteOutletsAPI {
    func favoriteOutlets(withRequestPayload requestPayload: FavoriteOutletsAPIRequestPayload) -> Observable<FavoriteOutletsAPIResponsePayload>
}

final class FavoriteOutletsAPIDefault: FavoriteOutletsAPI {

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

    func favoriteOutlets(withRequestPayload requestPayload: FavoriteOutletsAPIRequestPayload) -> Observable<FavoriteOutletsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/favorites/outlets")!

        let result = Observable.create {
            (observer: AnyObserver<FavoriteOutletsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<FavoriteOutletsAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct FavoriteOutletsAPIResponsePayload {
    let outlets: [Outlet]

    init(outlets: [Outlet]) {
        self.outlets = outlets
    }
}

extension FavoriteOutletsAPIResponsePayload: Serializable {
    typealias Type = FavoriteOutletsAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> FavoriteOutletsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize
        var outlets = [Outlet]()

        // Properties initialization
        if let value = json["outlets"] as? [AnyObject] {
            for outletRepresentation in value {
                if let outlet = Outlet.serialize(outletRepresentation) {
                    // Make sure that the outlet model is complete
                    if outlet.company != nil {
                        outlets.append(outlet)
                    }
                }
            }
        }

        let result = FavoriteOutletsAPIResponsePayload(outlets: outlets)
        return result
    }
}
