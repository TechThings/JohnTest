//
//  CurentReservationsAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 7/7/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct CurentReservationsAPIRequestPayload {
    let page: Int
    let limit: Int

    init(page: Int
        , limit: Int
        ) {
        self.page = page
        self.limit = limit
    }
}

extension CurentReservationsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["page"] = page
        parameters["limit"] = limit
        parameters["filter"] = "current"

        return parameters
    }
}

protocol CurentReservationsAPI {

    func getReservation(withRequestPayload requestPayload: CurentReservationsAPIRequestPayload) -> Observable<CurentReservationsAPIResponsePayload>
}

final class CurentReservationsAPIDefault: CurentReservationsAPI {

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

    func getReservation(withRequestPayload requestPayload: CurentReservationsAPIRequestPayload) -> Observable<CurentReservationsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/reservations")!

        let result = Observable.create {
            (observer: AnyObserver<CurentReservationsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<CurentReservationsAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct CurentReservationsAPIResponsePayload {
    let reservation: [Reservation]
    let pastCount: Int

    init(reservation: [Reservation], pastCount: Int) {
        self.reservation = reservation
        self.pastCount = pastCount
    }
}

extension CurentReservationsAPIResponsePayload: Serializable {
    typealias Type = CurentReservationsAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> CurentReservationsAPIResponsePayload? {

        guard let jsonReservation = jsonRepresentation?["current"] as? [AnyObject] else {
            return nil
        }

        var reservations = [Reservation]()
        var pastCount: Int = 0

        for value in jsonReservation {
            if let reservation = Reservation.serialize(value) {
                reservations.append(reservation)
            }
        }

        if let metaJson = jsonRepresentation?["meta"] as? [String: AnyObject] {
            if let value = metaJson["past_count"] as? Int {
                pastCount = value
            }
        }

        let result = CurentReservationsAPIResponsePayload(reservation: reservations, pastCount: pastCount)
        return result
    }
}
