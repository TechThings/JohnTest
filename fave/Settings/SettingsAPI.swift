//
//  SettingsAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/9/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CoreLocation

struct SettingsAPIRequestPayload {
    private let platform: String = "iOS"
    let buildNumber: Int
    let citySlug: String?

    init(
        buildNumber: Int
        , citySlug: String?
        ) {
        self.citySlug = citySlug
        self.buildNumber = buildNumber
    }
}

extension SettingsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["platform"] = platform
        parameters["build_number"] = buildNumber
        if let citySlug = citySlug { parameters["city"] = citySlug }

        return parameters
    }
}

protocol SettingsAPI {
    func updateSettings(withRequestPayload requestPayload: SettingsAPIRequestPayload) -> Observable<SettingsAPIResponsePayload>
}

final class SettingsAPIDefault: SettingsAPI {

    private let apiService: APIService
    private let networkService: NetworkService

    init(apiService: APIService = apiServiceDefault
        , networkService: NetworkService = networkServiceDefault
        ) {
        self.apiService = apiService
        self.networkService = networkService
    }

    func updateSettings(withRequestPayload requestPayload: SettingsAPIRequestPayload) -> Observable<SettingsAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v2/settings")

        let result = Observable.create {
            (observer: AnyObserver<SettingsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL!, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<SettingsAPIResponsePayload, NSError>) -> Void in
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

struct SettingsAPIResponsePayload {
    let settings: Settings

    init(settings: Settings) {
        self.settings = settings
    }
}

extension SettingsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> SettingsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }
        guard let settings = Settings.serialize(json) else {
            return nil
        }

        let result = SettingsAPIResponsePayload(
            settings: settings
        )
        return result
    }
}
