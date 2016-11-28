//
//  ListingsCollectionsAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

//struct ListingsCollectionsAPIRequestPayload {
//    let feature: Bool?
//    
//    init(feature: Bool?) {
//        self.feature = feature
//    }
//}

//extension ListingsCollectionsAPIRequestPayload: Serializable {
//    static func serialize(jsonRepresentation: AnyObject?) -> ListingsCollectionsAPIRequestPayload? {
//        
//        guard let json = jsonRepresentation as? [String : AnyObject] else {
//            return nil
//        }
//        
//        guard let feature = json["feature"] as? Bool else {
//            return nil
//        }
//        
//        let result = ListingsCollectionsAPIRequestPayload(feature: feature)
//        return result
//    }
//}

//extension ListingsCollectionsAPIRequestPayload: Deserializable {
//    func deserialize() -> [String: AnyObject] {
//        var parameters = [String: AnyObject]()
//        if let feature = feature {
//            parameters["feature"] = feature
//        }
//        return parameters
//    }
//}

extension ListingsCollectionsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

struct ListingsCollectionsAPIRequestPayload {
    init() {
    }
}

protocol ListingsCollectionsAPI {
    func listingsCollections(withRequestPayload requestPayload: ListingsCollectionsAPIRequestPayload) -> Observable<ListingsCollectionsAPIResponsePayload>

    // CC - Fix it
    func listingsCollections(withParameter parameters: [String: AnyObject]?) -> Observable<ListingsCollectionsAPIResponsePayload>
}

final class ListingsCollectionsAPIDefault: ListingsCollectionsAPI {

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

    func listingsCollections(withParameter parameters: [String : AnyObject]?) -> Observable<ListingsCollectionsAPIResponsePayload> {
        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/collections")!

        let result = Observable.create {
            (observer: AnyObserver< ListingsCollectionsAPIResponsePayload>) -> Disposable in

            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<ListingsCollectionsAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.onNext(value) }
                if let error = response.result.error { observer.onError(error) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result

    }

    func listingsCollections(withRequestPayload requestPayload: ListingsCollectionsAPIRequestPayload) -> Observable<ListingsCollectionsAPIResponsePayload> {

        let parameters = requestPayload.deserialize()
        return listingsCollections(withParameter: parameters)
    }
}

struct ListingsCollectionsAPIResponsePayload: ResponsePayload {
    let listingsCollections: [ListingsCollection]

    init(listingsCollections: [ListingsCollection]) {
        self.listingsCollections = listingsCollections
    }
}

extension ListingsCollectionsAPIResponsePayload: Serializable {
    typealias Type = ListingsCollectionsAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> ListingsCollectionsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize (copy from the object being serilized)
        var listingsCollections = [ListingsCollection]()

        // Properties initialization
        if let value = json["collections"] as? [AnyObject] {
            for representation in value {
                if let listingCollections = ListingsCollection.serialize(representation) {
                    listingsCollections.append(listingCollections)
                }
            }
        }

        // Verify properties and initialize object
        let result = ListingsCollectionsAPIResponsePayload(listingsCollections: listingsCollections)

        return result
    }
}
