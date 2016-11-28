//
//  UpdateParticipationStatusAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 18/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct UpdateParticipationStatusAPIRequestPayload {
    let channelURLString: String
    let participationStatus: String

    init(
        channelURLString: String
        , participationStatus: String
        ) {
        self.channelURLString = channelURLString
        self.participationStatus = participationStatus
    }
}

extension UpdateParticipationStatusAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["channel_url"] = channelURLString
        parameters["status"] = participationStatus

        return parameters
    }
}

protocol UpdateParticipationStatusAPI {
    func updateParticipationStatus(withRequestPayload requestPayload: UpdateParticipationStatusAPIRequestPayload) -> Observable<UpdateParticipationStatusAPIResponsePayload>
}

final class UpdateParticipationStatusAPIDefault: UpdateParticipationStatusAPI {

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

    func updateParticipationStatus(withRequestPayload requestPayload: UpdateParticipationStatusAPIRequestPayload) -> Observable<UpdateParticipationStatusAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/conversations/respond")!

        let result = Observable.create {
            (observer: AnyObserver<UpdateParticipationStatusAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .PUT, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<UpdateParticipationStatusAPIResponsePayload, NSError>) -> Void in
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

struct UpdateParticipationStatusAPIResponsePayload {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }
}

extension UpdateParticipationStatusAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> UpdateParticipationStatusAPIResponsePayload? {
        guard let channel = Channel.serialize(jsonRepresentation) else {return nil}

        let result = UpdateParticipationStatusAPIResponsePayload(channel: channel)

        return result
    }
}
