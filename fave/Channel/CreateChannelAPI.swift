//
//  CreateChannelAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 03/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct CreateChannelAPIRequestPayload {
    let channel: Channel

    init(
        channel: Channel
        ) {
        self.channel = channel
    }
}

extension CreateChannelAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = channel.deserialize()

        return parameters
    }
}

protocol CreateChannelAPI {
    func createChannel(withRequestPayload requestPayload: CreateChannelAPIRequestPayload) -> Observable<CreateChannelAPIResponsePayload>
}

final class CreateChannelAPIDefault: CreateChannelAPI {

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

    func createChannel(withRequestPayload requestPayload: CreateChannelAPIRequestPayload) -> Observable<CreateChannelAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/conversations")!

        let result = Observable.create {
            (observer: AnyObserver<CreateChannelAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .JSON, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<CreateChannelAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.onNext(value) }
                if let error = response.result.error { observer.onError(error) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct CreateChannelAPIResponsePayload {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }
}

extension CreateChannelAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> CreateChannelAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let channel = Channel.serialize(json) else {return nil}

        let result = CreateChannelAPIResponsePayload(
            channel: channel
        )
        return result
    }
}
