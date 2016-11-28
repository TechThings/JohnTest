//
//  RegisterUserAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct RegisterUserAPIRequestPayload {
    let name: String
    let email: String
    let promoCode: String
    let citySlug: String?

    init(
        name: String
        , email: String
        , promoCode: String
        , citySlug: String?
        ) {
        self.name = name
        self.email = email
        self.promoCode = promoCode
        self.citySlug = citySlug
    }
}

extension RegisterUserAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        var user = [String: AnyObject]()
        user["name"] = name
        user["email"] = email

        if let citySlug = citySlug {
            user["city"] = citySlug
        }

        // Add to Root Dictionary
        parameters["user"] = user

        return parameters
    }
}

protocol RegisterUserAPI {
    func registerUser(withRequestPayload requestPayload: RegisterUserAPIRequestPayload) -> Observable<RegisterUserAPIResponsePayload>
}

final class RegisterUserAPIDefault: RegisterUserAPI {

    let apiService: APIService
    let networkService: NetworkService
    let URL: NSURL!

    init(apiService: APIService = apiServiceDefault
        , networkService: NetworkService = networkServiceDefault
        ) {
        self.apiService = apiService
        self.networkService = networkService

        self.URL = apiService.baseURL.URLByAppendingPathComponent("api/fave/v1/users/basic")

    }

    func registerUser(withRequestPayload requestPayload: RegisterUserAPIRequestPayload) -> Observable<RegisterUserAPIResponsePayload> {

        let result = Observable.create {
            (observer: AnyObserver<RegisterUserAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .PUT, URL: self.URL, parameters: parameters, encoding: .JSON, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<RegisterUserAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct RegisterUserAPIResponsePayload {
    let user: User

    init(user: User) {
        self.user = user
    }
}

extension RegisterUserAPIResponsePayload: Serializable {
    typealias Type = RegisterUserAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> RegisterUserAPIResponsePayload? {
        guard let json = jsonRepresentation else {
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
            let result = RegisterUserAPIResponsePayload(user: user)
            return result
        }
        return nil
    }
}
