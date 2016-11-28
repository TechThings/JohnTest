//
//  ReservationInfoAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 8/24/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct ReservationInfoAPIRequestPayload {
    let id: Int

    init(
        id: Int
        ) {
        self.id = id
    }
}

extension ReservationInfoAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol ReservationInfoAPI {
    func getReservationInfo(withRequestPayload requestPayload: ReservationInfoAPIRequestPayload) -> Observable<ReservationInfoAPIResponsePayload>
}

final class ReservationInfoAPIDefault: ReservationInfoAPI {

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

    func getReservationInfo(withRequestPayload requestPayload: ReservationInfoAPIRequestPayload) -> Observable<ReservationInfoAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/reservations/\(requestPayload.id)")!

        let result = Observable.create {
            (observer: AnyObserver<ReservationInfoAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<ReservationInfoAPIResponsePayload, NSError>) -> Void in
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

struct ReservationInfoAPIResponsePayload {
    let reservation: Reservation

    init(reservation: Reservation) {
        self.reservation = reservation
    }
}

extension ReservationInfoAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ReservationInfoAPIResponsePayload? {
        guard let json = jsonRepresentation!["reservation"] as? [String : AnyObject] else {
            return nil
        }

        guard let reservation = Reservation.serialize(json) else {return nil}

        let result = ReservationInfoAPIResponsePayload(
            reservation: reservation
        )
        return result
    }
}
