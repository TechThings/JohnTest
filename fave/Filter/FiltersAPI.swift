//
//  FiltersAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 9/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct FiltersAPIRequestPayload {

    init(
        ) {
    }
}

extension FiltersAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()

        return parameters
    }
}

protocol FiltersAPI {
    func getFilters(withRequestPayload requestPayload: FiltersAPIRequestPayload) -> Observable<FiltersAPIResponsePayload>
}

final class FiltersAPIDefault: FiltersAPI {

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

    func getFilters(withRequestPayload requestPayload: FiltersAPIRequestPayload) -> Observable<FiltersAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v3/cities/\(citySlug)/filters")

        let result = Observable.create {
            (observer: AnyObserver<FiltersAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL!, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<FiltersAPIResponsePayload, NSError>) -> Void in
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

struct FiltersAPIResponsePayload {
    let categories: [Category]

    init(categories: [Category]) {
        self.categories = categories
    }
}

extension FiltersAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> FiltersAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        var categories = [Category]()

        guard let categoriesJson = json["filter_header"]?["data"] as? [AnyObject] else { return nil }

        for categoryJson in categoriesJson {
            if let category = Category.serialize(categoryJson) {
                categories.append(category)
            }
        }

        let result = FiltersAPIResponsePayload(categories: categories)
        return result
    }
}
