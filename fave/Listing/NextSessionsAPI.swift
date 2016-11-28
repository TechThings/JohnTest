//
//  NextSessionsAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 7/29/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct NextSessionsAPIRequestPayload {
    let listingId: Int

    init(
        listingId: Int
        ) {
        self.listingId = listingId
    }
}

extension NextSessionsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol NextSessionsAPI {
    func getNextSessions(withRequestPayload requestPayload: NextSessionsAPIRequestPayload) -> Observable<NextSessionsAPIResponsePayload>
}

final class NextSessionsAPIDefault: NextSessionsAPI {

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

    func getNextSessions(withRequestPayload requestPayload: NextSessionsAPIRequestPayload) -> Observable<NextSessionsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/listings/\(requestPayload.listingId)/class_sessions")!

        let result = Observable.create {
            (observer: AnyObserver<NextSessionsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<NextSessionsAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct NextSessionsAPIResponsePayload {
    let classSessions: [ClassSession]

    init(classSessions: [ClassSession]) {
        self.classSessions = classSessions
    }
}

extension NextSessionsAPIResponsePayload: Serializable {
    typealias Type = NextSessionsAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> NextSessionsAPIResponsePayload? {
        guard let json = jsonRepresentation?["class_sessions"] as? [String : AnyObject] else {
            return nil
        }

        var classSessions = [ClassSession]()
        if let value = json["class_sessions"] as? [AnyObject] {
            for representation in value {
                if let classSession = ClassSession.serialize(representation) {
                    classSessions.append(classSession)
                }
            }
        }

        return NextSessionsAPIResponsePayload(classSessions: classSessions)
    }
}
