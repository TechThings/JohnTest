//
//  PhoneNumberVerificationCodeAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct PhoneNumberVerificationCodeAPIRequestPayload {
    let phoneNumber: String

    init(
        phoneNumber: String
        ) {
        self.phoneNumber = phoneNumber
    }
}

extension PhoneNumberVerificationCodeAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["phone"] = phoneNumber

        return parameters
    }
}

protocol PhoneNumberVerificationCodeAPI {
    func phoneNumberVerificationCode(withRequestPayload requestPayload: PhoneNumberVerificationCodeAPIRequestPayload) -> Observable<PhoneNumberVerificationCodeAPIResponsePayload>
}

final class PhoneNumberVerificationCodeAPIDefault: PhoneNumberVerificationCodeAPI {

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

    func phoneNumberVerificationCode(withRequestPayload requestPayload: PhoneNumberVerificationCodeAPIRequestPayload) -> Observable<PhoneNumberVerificationCodeAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/auth")!

        let result = Observable.create {
            (observer: AnyObserver<PhoneNumberVerificationCodeAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<PhoneNumberVerificationCodeAPIResponsePayload, NSError>) -> Void in
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

final class PhoneNumberVerificationCodeStagingAPI: PhoneNumberVerificationCodeAPI {

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

    func phoneNumberVerificationCode(withRequestPayload requestPayload: PhoneNumberVerificationCodeAPIRequestPayload) -> Observable<PhoneNumberVerificationCodeAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/backdoor/request")!

        let result = Observable.create {
            (observer: AnyObserver<PhoneNumberVerificationCodeAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<PhoneNumberVerificationCodeAPIResponsePayload, NSError>) -> Void in
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

typealias PhoneNumberVerificationCodeRequestId = String
struct PhoneNumberVerificationCodeAPIResponsePayload {

    let requestId: PhoneNumberVerificationCodeRequestId

    init(requestId: PhoneNumberVerificationCodeRequestId) {
        self.requestId = requestId
    }
}

extension PhoneNumberVerificationCodeAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> PhoneNumberVerificationCodeAPIResponsePayload? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let requestId = json["request_id"] as? String else {return nil}

        let result = PhoneNumberVerificationCodeAPIResponsePayload(
            requestId: requestId
        )

        return result
    }
}
