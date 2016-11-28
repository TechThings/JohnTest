//
//  VerifyPhoneNumberAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct VerifyPhoneNumberAPIRequestPayload {
    let code: String
    let requestId: String

    init(
        requestId: String
        , code: String
        ) {
        self.requestId = requestId
        self.code = code

    }
}

extension VerifyPhoneNumberAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["code"] = code
        parameters["request_id"] = requestId

        return parameters
    }
}

protocol VerifyPhoneNumberAPI {
    func verifyPhoneNumber(withRequestPayload requestPayload: VerifyPhoneNumberAPIRequestPayload) -> Observable<VerifyPhoneNumberAPIResponsePayload>
}

final class VerifyPhoneNumberAPIDefault: VerifyPhoneNumberAPI {

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

    func verifyPhoneNumber(withRequestPayload requestPayload: VerifyPhoneNumberAPIRequestPayload) -> Observable<VerifyPhoneNumberAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/auth/verify")!

        let result = Observable.create {
            (observer: AnyObserver<VerifyPhoneNumberAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject { [weak self]
                (response: Response<VerifyPhoneNumberAPIResponsePayload, NSError>) -> Void in

                if let value = response.result.value {
                    self?.networkService.setCookiesFromResponse(response.response!)
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

final class VerifyPhoneNumberStagingAPI: VerifyPhoneNumberAPI {

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

    func verifyPhoneNumber(withRequestPayload requestPayload: VerifyPhoneNumberAPIRequestPayload) -> Observable<VerifyPhoneNumberAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/backdoor/login")!

        let result = Observable.create {
            (observer: AnyObserver<VerifyPhoneNumberAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject { [weak self]
                (response: Response<VerifyPhoneNumberAPIResponsePayload, NSError>) -> Void in

                if let value = response.result.value {
                    self?.networkService.setCookiesFromResponse(response.response!)
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

struct VerifyPhoneNumberAPIResponsePayload {
    var user: User

    init(user: User) {
        self.user = user
    }
}

extension VerifyPhoneNumberAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> VerifyPhoneNumberAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }
        // Properties initialization
        guard let value = json["user"] as? [String:AnyObject],
            let user = {
                return User.serialize(value)
            }() else {
                return nil
        }

        let result = VerifyPhoneNumberAPIResponsePayload(user: user)

        return result
    }
}
