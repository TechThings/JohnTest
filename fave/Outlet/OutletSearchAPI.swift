//
//  OutletsSearchAPI.swift
//  KFIT
//
//  Created by Nazih Shoura on 13/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct OutletsSearchRequestPayload {
    let query: String
    let orderBy: String
    let latitude: String?
    let longitude: String?
    let page: Int
    let outletsPerPage: Int
    let radius: Int?
    let excludeFavorited: Bool

    init (
        query: String
        , orderBy: String
        , latitude: String?
        , longitude: String?
        , page: Int
        , outletsPerPage: Int
        , radius: Int?
        , excludeFavorited: Bool
        ) {
        self.query = query
        self.orderBy = orderBy
        self.latitude = latitude
        self.longitude = longitude
        self.page = page
        self.outletsPerPage = outletsPerPage
        self.radius = radius
        self.excludeFavorited = excludeFavorited
    }
}

extension OutletsSearchRequestPayload: Deserializable {
    func deserialize() -> [String : AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["query"] = query
        parameters["order"] = orderBy
        if let longitude = longitude { parameters["longitude"] = longitude }
        if let latitude = latitude { parameters["latitude"] = latitude }

        parameters["page"] = page
        parameters["limit"] = outletsPerPage
        if let radius = radius { parameters["radius"] = radius }
        parameters["exclude_favorited"] = excludeFavorited

        return parameters
    }
}

protocol OutletsSearchAPI {
    func searchOutlets(requestPayload requestPayload: OutletsSearchRequestPayload) -> Observable<OutletsSearchResponsePayload>
    func searchOutletsFromDict(parameters parameters: [String: AnyObject]?) -> Observable<OutletsSearchResponsePayload>
}

final class OutletsSearchAPIDefault: OutletsSearchAPI {

    let apiService: APIService
    let networkService: NetworkService
    let cityProvider: CityProvider

    init(apiService: APIService = apiServiceDefault
        , networkService: NetworkService = networkServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        ) {
        self.apiService = apiService
        self.networkService = networkService
        self.cityProvider = cityProvider
    }

    func searchOutletsFromDict(parameters parameters: [String : AnyObject]?) -> Observable<OutletsSearchResponsePayload> {
        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/searches")!

        let result = Observable.create {
            (observer: AnyObserver<OutletsSearchResponsePayload>) -> Disposable in

            let URLRequest = try! self.networkService
                .URLRequest(
                    method: .GET
                    , URL: URL
                    , parameters: parameters
                    , encoding: .URL
                    , headers: nil
            )

            let request = self.networkService
                .managerWithDefaultConfiguration
                .request(URLRequest)

            request.responseObject {
                (response: Response<OutletsSearchResponsePayload, NSError>) -> Void in

                if let outletsSearchResponsePayload = response.result.value {
                    observer.on(.Next(outletsSearchResponsePayload))
                }

                if let error = response.result.error {
                    observer.on(.Error(error))

                }
                observer.on(.Completed)
            }

            return AnonymousDisposable {
                request.cancel()
            }
        }

        return result
    }

    func searchOutlets(requestPayload requestPayload: OutletsSearchRequestPayload) -> Observable<OutletsSearchResponsePayload> {
        let parameters = requestPayload.deserialize()
        return searchOutletsFromDict(parameters: parameters)
    }
}

struct OutletsSearchResponsePayload: ResponsePayload {
    var outlets = [Outlet]()

    init(outlets: [Outlet]) {
        self.outlets = outlets
    }
}

extension OutletsSearchResponsePayload: Serializable {
    typealias Type = OutletsSearchResponsePayload

    static func serialize(jsonRepresentation: AnyObject?) -> OutletsSearchResponsePayload? {

        // Properties to initialize
        var outlets = [Outlet]()

        // Properties initialization
        if let json = jsonRepresentation as? [String: AnyObject] {
            if let value = json["outlets"] as? [AnyObject] {
                for representation in value {
                    if let outlet = Outlet.serialize(representation) {
                        // Make sure that the outlet model is complete
                        if outlet.company != nil {
                        outlets.append(outlet)
                        }
                    }
                }
            }
        }

        // Verify properties and initialize object
        let result = OutletsSearchResponsePayload(outlets: outlets)
        return result
    }
}
