//
//  ChannelAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct ChannelAPIRequestPayload {
    let channelUrlString: String

    init(channelUrlString: String) {
        self.channelUrlString = channelUrlString
    }
}

extension ChannelAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol ChannelAPI {
    func channel(withRequestPayload requestPayload: ChannelAPIRequestPayload) -> Observable<ChannelAPIResponsePayload>
}

final class ChannelAPIDefault: ChannelAPI {

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

    func channel(withRequestPayload requestPayload: ChannelAPIRequestPayload) -> Observable<ChannelAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/conversations/\(requestPayload.channelUrlString)")!

        let result = Observable.create {
            (observer: AnyObserver<ChannelAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<ChannelAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.onNext(value) }
                if let error = response.result.error { observer.onError(error) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct ChannelAPIResponsePayload {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }
}

extension ChannelAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ChannelAPIResponsePayload? {

        guard let channel = Channel.serialize(jsonRepresentation) else {return nil}

        let result = ChannelAPIResponsePayload(
            channel: channel
        )
        return result
    }
}
