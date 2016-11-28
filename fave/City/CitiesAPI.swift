//
//  CitiesAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 07/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct CitiesAPIRequestPayload {

    init(
        ) {
    }
}

extension CitiesAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol CitiesAPI {
    func cities(withRequestPayload requestPayload: CitiesAPIRequestPayload) -> Observable<CitiesAPIResponsePayload>
}

final class CitiesAPIDefault: CitiesAPI {

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

    func cities(withRequestPayload requestPayload: CitiesAPIRequestPayload) -> Observable<CitiesAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/countries")!

        let result = Observable.create {
            (observer: AnyObserver<CitiesAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<CitiesAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct CitiesAPIResponsePayload {
    let cities: [City]

    init(cities: [City]) {
        self.cities = cities
    }
}

extension CitiesAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> CitiesAPIResponsePayload? {
        guard let json = jsonRepresentation?["countries"] as? [String: AnyObject] else {
            return nil
        }

        guard let cities = {
            () -> [City]? in
            var cities = [City]()
            // Transform the received value
            for (_, representation) in json {
                guard let countreyRepresentation = representation as? [AnyObject] else {continue}
                for representation in countreyRepresentation {
                    guard let cityRepresentation = representation as? [String : AnyObject] else {continue}
                    if let city = City.serialize(cityRepresentation) {
                        cities.append(city)
                    }
                }
            }
            if (cities.count > 0) {
                return cities
            }
            return nil
            }() else {return nil}

        let result = CitiesAPIResponsePayload(
            cities: cities
        )
        return result
    }
}
