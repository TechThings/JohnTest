//
//  LeaveChannelAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 18/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct LeaveChannelAPIRequestPayload {
    let channelURLString: String

    init(
        channelURLString: String
        ) {
        self.channelURLString = channelURLString
    }
}

extension LeaveChannelAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["channel_url"] = channelURLString

        return parameters
    }
}

protocol LeaveChannelAPI {
    func leaveChannel(withRequestPayload requestPayload: LeaveChannelAPIRequestPayload) -> Observable<LeaveChannelAPIResponsePayload>
}

final class LeaveChannelAPIDefault: LeaveChannelAPI {

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

    func leaveChannel(withRequestPayload requestPayload: LeaveChannelAPIRequestPayload) -> Observable<LeaveChannelAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/conversations/leave")!

        let result = Observable.create {
            (observer: AnyObserver<LeaveChannelAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<LeaveChannelAPIResponsePayload, NSError>) -> Void in
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

struct LeaveChannelAPIResponsePayload {

    init() {
    }
}

extension LeaveChannelAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> LeaveChannelAPIResponsePayload? {
        let result = LeaveChannelAPIResponsePayload()
        return result
    }
}
