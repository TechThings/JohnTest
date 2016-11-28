//
//  DeleteFavoriteOutletAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 02/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct DeleteFavoriteOutletAPIRequestPayload {

    // TODO: Change the name, using favoriteId rather than outletId
    let outletId: Int
    init(
        outletId: Int
        ) {
        self.outletId = outletId
    }
}

extension DeleteFavoriteOutletAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        parameters["id"] = outletId
        return parameters
    }
}

protocol DeleteFavoriteOutletAPI {
    func deleteFavoriteOutlet(withRequestPayload requestPayload: DeleteFavoriteOutletAPIRequestPayload) -> Observable<DeleteFavoriteOutletAPIResponsePayload>
}

final class DeleteFavoriteOutletAPIDefault: DeleteFavoriteOutletAPI {

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

    func deleteFavoriteOutlet(withRequestPayload requestPayload: DeleteFavoriteOutletAPIRequestPayload) -> Observable<DeleteFavoriteOutletAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/favorites/outlets/\(requestPayload.outletId)")!

        let result = Observable.create {
            (observer: AnyObserver<DeleteFavoriteOutletAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .DELETE, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration
                .request(URLRequest)

            request.responseObject {
                (response: Response<DeleteFavoriteOutletAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct DeleteFavoriteOutletAPIResponsePayload {
    let success: Bool

    init(success: Bool) {
        self.success = success
    }
}

extension DeleteFavoriteOutletAPIResponsePayload: Serializable {
    typealias Type = DeleteFavoriteOutletAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> DeleteFavoriteOutletAPIResponsePayload? {
        guard let _ = jsonRepresentation?["outlet"] as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize
        let success: Bool = true

        let result = DeleteFavoriteOutletAPIResponsePayload(success: success)
        return result
    }
}
