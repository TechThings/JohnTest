//
//  PaymentReceiptsAPI.swift
//  fave
//
//  Created by Michael Cheah on 7/12/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

// WIP. This is new. Don't delete

struct PaymentReceiptsAPIRequestPayload {
    init () {
    }
}

extension PaymentReceiptsAPIRequestPayload: Deserializable {
    func deserialize() -> [String:AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol PaymentReceiptsAPI {
    func getReceipt(withRequestPayload requestPayload: PaymentReceiptsAPIRequestPayload) -> Observable<PaymentReceiptsAPIResponsePayload>
}

final class PaymentReceiptsAPIDefault: PaymentReceiptsAPI {

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

    func getReceipt(withRequestPayload requestPayload: PaymentReceiptsAPIRequestPayload) -> Observable<PaymentReceiptsAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/receipts")!

        let result = Observable.create {
            (observer: AnyObserver<PaymentReceiptsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<PaymentReceiptsAPIResponsePayload, NSError>) -> Void in
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

struct PaymentReceiptsAPIResponsePayload {
    let receipts: [PaymentReceipt]

    init(receipts: [PaymentReceipt]) {
        self.receipts = receipts
    }
}

extension PaymentReceiptsAPIResponsePayload: Serializable {
    typealias Type = PaymentReceiptsAPIResponsePayload

    static func serialize(jsonRepresentation: AnyObject?) -> PaymentReceiptsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        var receipts = [PaymentReceipt]()

        // Properties initialization
        if let value = json["receipts"] as? [AnyObject] {
            for representation in value {
                if let method = PaymentReceipt.serialize(representation) {
                    receipts.append(method)
                }
            }
        }

        let result = PaymentReceiptsAPIResponsePayload(receipts: receipts)

        return result
    }
}
