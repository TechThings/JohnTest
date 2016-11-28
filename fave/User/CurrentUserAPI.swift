//
//  CurrentUserAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct CurrentUserAPIRequestPayload {
}

extension CurrentUserAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol CurrentUserAPI {
    func currentUser(withRequestPayload requestPayload: CurrentUserAPIRequestPayload) -> Observable<CurrentUserAPIResponsePayload>
}

final class CurrentUserAPIDefault: CurrentUserAPI {

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

    func currentUser(withRequestPayload requestPayload: CurrentUserAPIRequestPayload) -> Observable<CurrentUserAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/users/current_user")!

        let result = Observable.create {
            (observer: AnyObserver<CurrentUserAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<CurrentUserAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct CurrentUserAPIResponsePayload {
    let user: User

    init(user: User) {
        self.user = user
    }
}

extension CurrentUserAPIResponsePayload: Serializable {
    typealias Type = CurrentUserAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> CurrentUserAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize
        var user: User!

        // Properties initialization
        if let value = json["user"] as? [String : AnyObject] {
            user = User.serialize(value)
        }

        // Verify properties and initialize object
        if let user = user {
            let result = CurrentUserAPIResponsePayload(user: user)
            return result
        }
        return nil
    }
}
