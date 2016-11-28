//
//  PendingActionAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 8/23/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct PendingNotificationsAPIRequestPayload {

    init(
        ) {
    }
}

extension PendingNotificationsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()

        return parameters
    }
}

protocol PendingNotificationsAPI {
    func pendingNotifications(withRequestPayload requestPayload: PendingNotificationsAPIRequestPayload) -> Observable<PendingNotificationsAPIResponsePayload>
}

final class PendingNotificationsAPIDefault: PendingNotificationsAPI {

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

    func pendingNotifications(withRequestPayload requestPayload: PendingNotificationsAPIRequestPayload) -> Observable<PendingNotificationsAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v2/users/pending_notifications")!

        let result = Observable.create {
            (observer: AnyObserver<PendingNotificationsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<PendingNotificationsAPIResponsePayload, NSError>) -> Void in
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

struct PendingNotificationsAPIResponsePayload {
    let pendingNotifications: [PendingNotification]

    init(pendingNotifications: [PendingNotification]) {
        self.pendingNotifications = pendingNotifications
    }
}

extension PendingNotificationsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> PendingNotificationsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        var pendingNotifications = [PendingNotification]()

        if let pendingNotification = PendingNotification.serialize(json) {
            pendingNotifications.append(pendingNotification)
        }

        let result = PendingNotificationsAPIResponsePayload(pendingNotifications: pendingNotifications)
        return result
    }
}
