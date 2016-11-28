//
//  ChannelsAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct ChannelsAPIRequestPayload {

    init(
        ) {
    }
}

extension ChannelsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol ChannelsAPI {
    func channels(withRequestPayload requestPayload: ChannelsAPIRequestPayload) -> Observable<ChannelsAPIResponsePayload>
}

final class ChannelsAPIDefault: ChannelsAPI {

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

    func channels(withRequestPayload requestPayload: ChannelsAPIRequestPayload) -> Observable<ChannelsAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/conversations")!

        let result = Observable.create {
            (observer: AnyObserver<ChannelsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<ChannelsAPIResponsePayload, NSError>) -> Void in
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

struct ChannelsAPIResponsePayload {
    let channels: [Channel]

    init(channels: [Channel]) {
        self.channels = channels
    }
}

extension ChannelsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ChannelsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [AnyObject] else {
            return nil
        }

        let channels = { () -> [Channel] in
            var channels = [Channel]()
            for channelRepresentaion in json {
                if let channel = Channel.serialize(channelRepresentaion) { channels.append(channel)}
            }
            return channels
        }()

        let result = ChannelsAPIResponsePayload(
            channels: channels
        )
        return result
    }
}
