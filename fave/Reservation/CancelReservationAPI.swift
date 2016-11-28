//
//  CancelReservationAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct CancelReservationAPIRequestPayload {
    let reservationId: Int

    init(
        reservationId: Int
        ) {
        self.reservationId = reservationId
    }
}

extension CancelReservationAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        return [String: AnyObject]()
    }
}

protocol CancelReservationAPI {
    func cancelReservation(withRequestPayload requestPayload: CancelReservationAPIRequestPayload) -> Observable<CancelReservationAPIResponsePayload>
}

final class CancelReservationAPIDefault: CancelReservationAPI {

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

    func cancelReservation(withRequestPayload requestPayload: CancelReservationAPIRequestPayload) -> Observable<CancelReservationAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/reservations/\(requestPayload.reservationId)/cancel")!

        let result = Observable.create {
            (observer: AnyObserver<CancelReservationAPIResponsePayload>) -> Disposable in

            let URLRequest = try! self.networkService
                .URLRequest(method: .PUT, URL: URL, parameters: nil, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<CancelReservationAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct CancelReservationAPIResponsePayload {
    let reservation: Reservation

    init(reservation: Reservation) {
        self.reservation = reservation
    }
}

extension CancelReservationAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> CancelReservationAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let reservationJson = json["reservation"] as? [String:AnyObject],
        let reservation = { () -> Reservation? in
            return Reservation.serialize(reservationJson)
            }() else {return nil}

        let result = CancelReservationAPIResponsePayload(
            reservation: reservation
        )
        return result
    }
}
