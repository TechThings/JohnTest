//
//  ConfirmReservationAPI.swift
//  fave
//
//  Created by Michael Cheah on 7/9/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct ConfirmReservationAPIRequestPayload {
    let reservableId: Int
    let reservableType: String
    let reservationCount: Int
    let paymentGateway: String
    let cvc: String?

    init(reservableId: Int
        , reservableType: String
        , reservationCount: Int
        , paymentGateway: String
        , cvc: String? = nil) {
        self.reservableId = reservableId
        self.reservableType = reservableType
        self.reservationCount = reservationCount
        self.paymentGateway = paymentGateway
        self.cvc = cvc
    }
}

extension ConfirmReservationAPIRequestPayload: Deserializable {
    func deserialize() -> [String:AnyObject] {
        var parameters = [String: AnyObject]()
        var reservation = [String: AnyObject]()

        reservation["reservable_id"] = reservableId
        reservation["reservable_type"] = reservableType
        reservation["reservation_count"] = reservationCount
        reservation["payment_method"] = paymentGateway
        if let cvc = self.cvc {
            reservation["cvc"] = cvc
        }
        // Add to Root Dictionary
        parameters["reservation"] = reservation

        return parameters
    }
}

protocol ConfirmReservationAPI {
    func confirmReservation(withRequestPayload requestPayload: ConfirmReservationAPIRequestPayload) -> Observable<ConfirmReservationAPIResponsePayload>
}

final class ConfirmReservationAPIDefault: ConfirmReservationAPI {

    private let apiService: APIService
    private let networkService: NetworkService
    private let cityProvider: CityProvider

    init(apiService: APIService = apiServiceDefault,
         networkService: NetworkService = networkServiceDefault
            , cityProvider: CityProvider = cityProviderDefault
    ) {
        self.apiService = apiService
        self.networkService = networkService
        self.cityProvider = cityProvider
    }

    func confirmReservation(withRequestPayload requestPayload: ConfirmReservationAPIRequestPayload) -> Observable<ConfirmReservationAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v2/cities/\(citySlug)/reservations")!

        let result = Observable.create {
            (observer: AnyObserver<ConfirmReservationAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
            .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .JSON, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<ConfirmReservationAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value {
                    observer.on(.Next(value))
                }
                if let error = response.result.error {
                    observer.on(.Error(error))
                }
                observer.on(.Completed)
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
        return result
    }
}

enum ConfirmReservationAPIResponsePayloadType {
    case ReservationSuccessfull(data: Reservation)
    case Adyen3DRequired(data: AdyenAuth3DS)
    case CVCRequired
}

struct ConfirmReservationAPIResponsePayload: ResponsePayload {
    let response: ConfirmReservationAPIResponsePayloadType

    init(response: ConfirmReservationAPIResponsePayloadType) {
        self.response = response
    }
}

extension ConfirmReservationAPIResponsePayload: Serializable {
    typealias Type = ConfirmReservationAPIResponsePayload

    static func serialize(jsonRepresentation: AnyObject?) -> ConfirmReservationAPIResponsePayload? {
        logger.log(self, reseavedResponse: jsonRepresentation, loggingMode: .debug, logingTags: [.payment, .confirmReservation])

        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        /*
            need to check 3 cases here:
         1. success, main key will be `reservation`
         2. CCV required, key will be `cvc_required`
         3. 3ds authentication required, key will be `adyen_authenticate3ds`
         */

        // if this key exists, it definitely requires 3ds
        if let _ = json["cvc_required"] {
            return ConfirmReservationAPIResponsePayload(response: .CVCRequired)
        }

        if let adyenAuthentication: [String: AnyObject] = json["adyen_authenticate3ds"] as? [String: AnyObject] {
            if let adyen3ds = AdyenAuth3DS.serialize(adyenAuthentication) {
                return ConfirmReservationAPIResponsePayload(response: .Adyen3DRequired(data: adyen3ds))
            }
        }

        guard let reservation: Reservation = { () -> Reservation? in
            guard let reservationRepresentation = json["reservation"] as? [String:AnyObject] else { return nil }
            let result = Reservation.serialize(reservationRepresentation)
            return result
        }()
        else {
            return nil
        }

        let result = ConfirmReservationAPIResponsePayload(response: .ReservationSuccessfull(data: reservation))
        return result
    }
}
