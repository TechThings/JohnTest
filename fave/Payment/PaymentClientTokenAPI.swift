////
////  PaymentClientTokenAPI.swift
////  FAVE
////
////  Created by Nazih Shoura on 05/07/2016.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import Alamofire
//
//struct PaymentClientTokenAPIRequestPayload {
//
//    init() {
//    }
//}
//
//extension PaymentClientTokenAPIRequestPayload: Deserializable {
//    func deserialize() -> [String:AnyObject] {
//        let parameters = [String: AnyObject]()
//        return parameters
//    }
//}
//
//protocol PaymentClientTokenAPI {
//    func paymentClientToken(withRequestPayload requestPayload: PaymentClientTokenAPIRequestPayload) -> Observable<PaymentClientTokenAPIResponsePayload>
//}
//
//
//final class PaymentClientTokenAPIDefault: PaymentClientTokenAPI {
//
//    private let apiService: APIService
//    private let networkService: NetworkService
//    private let app: AppType
//    
//    init(apiService: APIService = apiServiceDefault,
//         networkService: NetworkService = networkServiceDefault
//        , app: AppType = appDefault
//        ) {
//        self.apiService = apiService
//        self.networkService = networkService
//        self.app = app
//    }
//
//    func paymentClientToken(withRequestPayload requestPayload: PaymentClientTokenAPIRequestPayload) -> Observable<PaymentClientTokenAPIResponsePayload> {
//        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/payments/client_token")!
//
//        let result = Observable.create {
//            (observer: AnyObserver<PaymentClientTokenAPIResponsePayload>) -> Disposable in
//
//            let parameters = requestPayload.deserialize()
//            let URLRequest = try! self.networkService
//            .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
//            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)
//
//            // TAG: Logging
//            #if DEBUG
////                print("Requesting \(URLRequest.description) \n**********\n")
//            #endif
//
//            request.responseObject {
//                (response: Response<PaymentClientTokenAPIResponsePayload, NSError>) -> Void in
//                if let value = response.result.value {
//                    observer.on(.Next(value))
//                }
//                if let error = response.result.error {
//                    observer.on(.Error(error))
//                }
//                observer.on(.Completed)
//            }
//            return AnonymousDisposable {
//                request.cancel()
//            }
//        }
//        return result
//    }
//}
//
//struct PaymentClientTokenAPIResponsePayload {
//    let token: String
//
//    init(token: String) {
//        self.token = token
//    }
//}
//
//extension PaymentClientTokenAPIResponsePayload: Serializable {
//    typealias Type = PaymentClientTokenAPIResponsePayload
//
//    static func serialize(jsonRepresentation: AnyObject?) -> PaymentClientTokenAPIResponsePayload? {
//        guard let json = jsonRepresentation as? [String:AnyObject] else {
//            return nil
//        }
//
//        guard let token = {
//            return json["token"] as? String
//        }() else {
//            return nil
//        }
//
//        let result = PaymentClientTokenAPIResponsePayload(token: token)
//        return result
//    }
//}
//
