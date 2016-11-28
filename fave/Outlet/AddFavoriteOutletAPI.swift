//
//  AddFavoriteOutletAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 02/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct AddFavoriteOutletAPIRequestPayload {
    let outletId: Int

    init(outletId: Int) {
        self.outletId = outletId
    }
}

extension AddFavoriteOutletAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        parameters["favorite[outlet_id]"] = outletId
        return parameters
    }
}

protocol AddFavoriteOutletAPI {
    func addFavoriteOutlet(withRequestPayload requestPayload: AddFavoriteOutletAPIRequestPayload) -> Observable<AddFavoriteOutletAPIResponsePayload>
}

final class AddFavoriteOutletAPIDefault: AddFavoriteOutletAPI {
    // MARK:- Dependancies
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

    func addFavoriteOutlet(withRequestPayload requestPayload: AddFavoriteOutletAPIRequestPayload) -> Observable<AddFavoriteOutletAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/favorites/outlets")!

        let result = Observable.create {
            (observer: AnyObserver<AddFavoriteOutletAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<AddFavoriteOutletAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct AddFavoriteOutletAPIResponsePayload {
    let favourateId: Int

    init(favourateId: Int) {
        self.favourateId = favourateId
    }
}

extension AddFavoriteOutletAPIResponsePayload: Serializable {
    typealias Type = AddFavoriteOutletAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> AddFavoriteOutletAPIResponsePayload? {
        guard let json = jsonRepresentation?["outlet"] as? [String : AnyObject] else {
            return nil
        }

        // Properties initialization
        guard let favourateId = json["favorite_id"] as? Int else { return nil}

        let result = AddFavoriteOutletAPIResponsePayload(favourateId: favourateId)
        return result
    }
}
