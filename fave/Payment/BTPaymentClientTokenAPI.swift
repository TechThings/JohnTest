//
//  BTPaymentClientTokenAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct BTPaymentClientTokenAPIRequestPayload {
    let paymentGateway: String
    init(paymentGateway: String) {
        self.paymentGateway = paymentGateway
    }
}

extension BTPaymentClientTokenAPIRequestPayload: Deserializable {
    func deserialize() -> [String:AnyObject] {
        var parameters = [String: AnyObject]()
        parameters["payment_gateway"] = self.paymentGateway
        return parameters
    }
}

protocol BTPaymentClientTokenAPI {
    func btPaymentClientToken(withRequestPayload requestPayload: BTPaymentClientTokenAPIRequestPayload) -> Observable<BTPaymentClientTokenAPIResponsePayload>
}

final class BTPaymentClientTokenAPIDefault: BTPaymentClientTokenAPI {

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

    func btPaymentClientToken(withRequestPayload requestPayload: BTPaymentClientTokenAPIRequestPayload) -> Observable<BTPaymentClientTokenAPIResponsePayload> {
        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/payments/client_token")!

        let result = Observable.create {
            (observer: AnyObserver<BTPaymentClientTokenAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<BTPaymentClientTokenAPIResponsePayload, NSError>) -> Void in
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

struct BTPaymentClientTokenAPIResponsePayload {
    let token: String

    init(token: String) {
        self.token = token
    }
}

extension BTPaymentClientTokenAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> BTPaymentClientTokenAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        guard let token = {
            return json["token"] as? String
            }() else {
                return nil
        }

        let result = BTPaymentClientTokenAPIResponsePayload(token: token)
        return result
    }
}
