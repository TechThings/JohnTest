//
//  NotifyPaymentFinishedAPI.swift
//  FAVE
//
//  Created by Light Dream on 18/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct NotifyPaymentFinishedAPIRequestPayload {
    let orderId: String
    let transactionId: String
    let paymentGateway: String

    init(
        orderId: String
        , transactionId: String
        , paymentGateway: String
        ) {
        self.orderId = orderId
        self.transactionId = transactionId
        self.paymentGateway = paymentGateway
    }
}

extension NotifyPaymentFinishedAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["order_id"] = orderId
        parameters["transaction_id"] = transactionId
        parameters["payment_gateway"] = paymentGateway

        return parameters
    }
}

protocol NotifyPaymentFinishedAPI {
    func notifyPaymentFinish(withRequestPayload requestPayload: NotifyPaymentFinishedAPIRequestPayload) -> Observable<NotifyPaymentFinishedAPIResponsePayload>
}

class NotifyPaymentFinishedAPIDefault: NotifyPaymentFinishedAPI {

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

    func notifyPaymentFinish(withRequestPayload requestPayload: NotifyPaymentFinishedAPIRequestPayload) -> Observable<NotifyPaymentFinishedAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v2/payments/notify_finish")

        let result = Observable.create {
            (observer: AnyObserver<NotifyPaymentFinishedAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL!, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<NotifyPaymentFinishedAPIResponsePayload, NSError>) -> Void in
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

struct NotifyPaymentFinishedAPIResponsePayload {
    /// this is in ms
    let refreshInterval: Double

    init(refreshInterval: Double) {
        self.refreshInterval = refreshInterval
    }
}

extension NotifyPaymentFinishedAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> NotifyPaymentFinishedAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let refreshInterval = json["refresh_interval_ms"] as? Double else { return nil }

        let result = NotifyPaymentFinishedAPIResponsePayload(refreshInterval: refreshInterval)
        return result
    }
}
