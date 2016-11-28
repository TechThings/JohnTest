//
//  PaymentMethodsAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct PaymentMethodsAPIRequestPayload {

    init() {
    }
}

extension PaymentMethodsAPIRequestPayload: Deserializable {
    func deserialize() -> [String:AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol PaymentMethodsAPI {
    func paymentsMethods(withRequestPayload requestPayload: PaymentMethodsAPIRequestPayload) -> Observable<PaymentMethodsAPIResponsePayload>
}

final class PaymentMethodsAPIDefault: PaymentMethodsAPI {

    private let apiService: APIService
    private let networkService: NetworkService
    private let app: AppType

    init(apiService: APIService = apiServiceDefault,
         networkService: NetworkService = networkServiceDefault
        , app: AppType = appDefault
    ) {
        self.apiService = apiService
        self.networkService = networkService
        self.app = app
    }

    func paymentsMethods(withRequestPayload requestPayload: PaymentMethodsAPIRequestPayload) -> Observable<PaymentMethodsAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/payments/methods")!

        let result = Observable.create {
            (observer: AnyObserver<PaymentMethodsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
            .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<PaymentMethodsAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value {
                    observer.on(.Next(value))
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
}

struct PaymentMethodsAPIResponsePayload {
    let paymentMethods: [PaymentMethod]

    init(paymentMethods: [PaymentMethod]) {
        self.paymentMethods = paymentMethods
    }
}

extension PaymentMethodsAPIResponsePayload: Serializable {
    typealias Type = PaymentMethodsAPIResponsePayload

    static func serialize(jsonRepresentation: AnyObject?) -> PaymentMethodsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        // Properties to initialize
        var paymentMethods = [PaymentMethod]()
        if let paymentMethod = PaymentMethod.serialize(json["payment_method"]) {
            paymentMethods.append(paymentMethod)
        } else if let value = json["payment_method"] as? [AnyObject] {
            for representation in value {
                if let paymentMethod = PaymentMethod.serialize(representation) {
                    paymentMethods.append(paymentMethod)
                }
            }
        }

//        guard paymentMethods.count > 0  else { return nil}

        let result = PaymentMethodsAPIResponsePayload(
                paymentMethods: paymentMethods)
        return result
    }
}
