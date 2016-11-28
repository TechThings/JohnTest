//
//  NearestCityAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 30/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct NearestCityAPIRequestPayload {
    let latitude: Double
    let longitude: Double

    init(
        latitude: Double
        , longitude: Double
        ) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension NearestCityAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["latitude"] = latitude
        parameters["longitude"] = longitude

        return parameters
    }
}

protocol NearestCityAPI {
    func nearestCity(withRequestPayload requestPayload: NearestCityAPIRequestPayload) -> Observable<NearestCityAPIResponsePayload>
}

final class NearestCityAPIDefault: NearestCityAPI {

    let apiService: APIService
    let networkService: NetworkService

    init(apiService: APIService = apiServiceDefault
        , networkService: NetworkService = networkServiceDefault
        ) {
        self.apiService = apiService
        self.networkService = networkService
    }

    func nearestCity(withRequestPayload requestPayload: NearestCityAPIRequestPayload) -> Observable<NearestCityAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/nearest")!

        let result = Observable.create {
            (observer: AnyObserver<NearestCityAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<NearestCityAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct NearestCityAPIResponsePayload {
    let city: City

    init(city: City) {
        self.city = city
    }
}

extension NearestCityAPIResponsePayload: Serializable {
    typealias Type = NearestCityAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> NearestCityAPIResponsePayload? {
        guard let json = jsonRepresentation else { return nil }

        // Properties to initialize
        var city: City!

        // Properties initialization
        if let value = json["city"] as? [String : AnyObject] {
            city =  City.serialize(value)
        }

        // Verify properties and initialize object
        if let city = city {
            let result = NearestCityAPIResponsePayload(city: city)
            return result
        }
        return nil
    }
}
