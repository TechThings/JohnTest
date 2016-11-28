//
//  HomeSectionsAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct HomeSectionsAPIRequestPayload {

    init(
        ) {
    }
}

extension HomeSectionsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol HomeSectionsAPI {
    func homeSections(withRequestPayload requestPayload: HomeSectionsAPIRequestPayload) -> Observable<HomeSectionsAPIResponsePayload>
}

final class HomeSectionsAPIDefault: HomeSectionsAPI {

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

    func homeSections(withRequestPayload requestPayload: HomeSectionsAPIRequestPayload) -> Observable<HomeSectionsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/sections_order")!

        let result = Observable.create {
            (observer: AnyObserver<HomeSectionsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<HomeSectionsAPIResponsePayload, NSError>) -> Void in
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

struct HomeSectionsAPIResponsePayload {
    let homeSections: [HomeSection]

    init(homeSections: [HomeSection]) {
        self.homeSections = homeSections
    }
}

extension HomeSectionsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> HomeSectionsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        var homeSections = [HomeSection]()
        if let sections = json["sections_order"] as? [AnyObject] {
            for item in sections {
                if let homeSection = HomeSection.serialize(item) {
                    homeSections.append(homeSection)
                }
            }
        }

        let result = HomeSectionsAPIResponsePayload(
            homeSections: homeSections
        )
        return result
    }
}
