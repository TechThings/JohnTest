//
//  AddPaymentMethodAPI.swift
//  fave
//
//  Created by Michael Cheah on 7/8/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct AddPaymentMethodAPIRequestPayload {
    let nonce: String
    let gateway: String
    let cardLast4Digits: String?

    init(nonce: String
        , gateway: String
        , cardLast4Digits: String?) {
        self.nonce = nonce
        self.gateway = gateway
        self.cardLast4Digits = cardLast4Digits
    }
}

extension AddPaymentMethodAPIRequestPayload: Deserializable {
    func deserialize() -> [String:AnyObject] {
        var parameters = [String: AnyObject]()
        var payment = [String: AnyObject]()

        payment["nonce"] = nonce
        payment["gateway"] = gateway
        payment["identifier"] = cardLast4Digits

        // Add to Root Dictionary
        parameters["payment"] = payment

        return parameters
    }
}

protocol AddPaymentMethodAPI {
    func addPaymentMethod(withRequestPayload requestPayload: AddPaymentMethodAPIRequestPayload) -> Observable<AddPaymentMethodAPIResponsePayload>
}

final class AddPaymentMethodAPIDefault: AddPaymentMethodAPI {

    private let apiService: APIService
    private let networkService: NetworkService

    init(apiService: APIService = apiServiceDefault,
         networkService: NetworkService = networkServiceDefault
        ) {
        self.apiService = apiService
        self.networkService = networkService
    }

    func addPaymentMethod(withRequestPayload requestPayload: AddPaymentMethodAPIRequestPayload) -> Observable<AddPaymentMethodAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v2/payments")!

        let result = Observable.create {
            (observer: AnyObserver<AddPaymentMethodAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .JSON, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<AddPaymentMethodAPIResponsePayload, NSError>) -> Void in
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

enum AddPaymentMethodAPIResponsePayloadActionType {
    case Adyen3DSRequired(data: AdyenAuth3DS)
    case PaymentMethods(data: [PaymentMethod])
}

struct AddPaymentMethodAPIResponsePayload {
    let response: AddPaymentMethodAPIResponsePayloadActionType

    init(response: AddPaymentMethodAPIResponsePayloadActionType) {
        self.response = response
    }
}

extension AddPaymentMethodAPIResponsePayload: Serializable {

    static func serialize(jsonRepresentation: AnyObject?) -> AddPaymentMethodAPIResponsePayload? {
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

        guard paymentMethods.count > 0  else {
            // check if it's adyen 3ds auth
            if let adyen3ds = AdyenAuth3DS.serialize(json["adyen_authenticate3ds"]) {
                return AddPaymentMethodAPIResponsePayload(response: .Adyen3DSRequired(data: adyen3ds))
            }
            return nil
        }

        let result = AddPaymentMethodAPIResponsePayload(response: .PaymentMethods(data: paymentMethods))
        return result

    }
}
