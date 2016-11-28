//
//  PastReservationsAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 7/7/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct PastReservationsAPIRequestPayload {
    let page: Int
    let limit: Int

    init(page: Int
        , limit: Int
        ) {
        self.page = page
        self.limit = limit
    }
}

extension PastReservationsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["filter"] = "past"
        parameters["page"] = page
        parameters["limit"] = limit

        return parameters
    }
}

protocol PastReservationsAPI {

    func getReservation(withRequestPayload requestPayload: PastReservationsAPIRequestPayload) -> Observable<PastReservationsAPIResponsePayload>
}

final class PastReservationsAPIDefault: PastReservationsAPI {

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

    func getReservation(withRequestPayload requestPayload: PastReservationsAPIRequestPayload) -> Observable<PastReservationsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/reservations")!

        let result = Observable.create {
            (observer: AnyObserver<PastReservationsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<PastReservationsAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct PastReservationsAPIResponsePayload {
    let reservation: [Reservation]

    init(reservation: [Reservation]) {
        self.reservation = reservation
    }
}

extension PastReservationsAPIResponsePayload: Serializable {
    typealias Type = PastReservationsAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> PastReservationsAPIResponsePayload? {

        guard let json = jsonRepresentation?["past"] as? [AnyObject] else {
            return nil
        }

        var reservations = [Reservation]()
        for value in json {
            if let reservation = Reservation.serialize(value) {
                reservations.append(reservation)
            }
        }

        let result = PastReservationsAPIResponsePayload(reservation: reservations)
        return result
    }
}
