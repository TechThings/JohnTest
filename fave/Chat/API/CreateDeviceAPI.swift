//
//  CreateDeviceAPI.swift
//  FAVE
//
//  Created by Michael Cheah on 8/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct CreateDeviceAPIRequestPayload {
    let gcmID: String
    let advertisingId: String

    init(gcmID: String,
         advertisingId: String = appDefault.advertisingId) {
        self.gcmID = gcmID
        self.advertisingId = advertisingId
    }
}

extension CreateDeviceAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        parameters["gcm_id"] = self.gcmID
        parameters["advertising_id"] = self.advertisingId

        return parameters
    }
}

protocol CreateDeviceAPI {
    func createDevice(withRequestPayload requestPayload: CreateDeviceAPIRequestPayload) -> Observable<CreateDeviceAPIResponsePayload>
}

final class CreateDeviceAPIDefault: CreateDeviceAPI {

    private let apiService: APIService
    private let networkService: NetworkService
    private let app: AppType

    init(apiService: APIService = apiServiceDefault,
         networkService: NetworkService = networkServiceDefault,
         app: AppType = appDefault
        ) {
        self.app = app
        self.apiService = apiService
        self.networkService = networkService
    }

    func createDevice(withRequestPayload requestPayload: CreateDeviceAPIRequestPayload) -> Observable<CreateDeviceAPIResponsePayload> {
        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/devices")!

        let result = Observable.create {
            (observer: AnyObserver<CreateDeviceAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<CreateDeviceAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct CreateDeviceAPIResponsePayload {
    let status: String

    init(status: String) {
        self.status = status
    }
}

extension CreateDeviceAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> CreateDeviceAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let status = json["status"] as? String else {return nil}

        let result = CreateDeviceAPIResponsePayload(
            status: status
        )
        return result
    }
}
