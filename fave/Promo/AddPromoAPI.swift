//
//  AddPromoAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct AddPromoAPIRequestPayload {
    let code: String

    init (code: String) {
        self.code = code
    }
}

extension AddPromoAPIRequestPayload: Deserializable {
    func deserialize() -> [String : AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["code"] = self.code

        return parameters
    }
}

protocol AddPromoAPI {
    func addPromo(withRequestPayload requestPayload: AddPromoAPIRequestPayload) -> Observable<AddPromoAPIResponsePayload>

    func addPromo(atCheckoutOfferId offerId: Int, requestPayload: AddPromoAPIRequestPayload) -> Observable<AddPromoAPIAtCheckOutResponsePayload>
}

final class AddPromoAPIDefault: AddPromoAPI {

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

    func addPromo(atCheckoutOfferId offerId: Int, requestPayload: AddPromoAPIRequestPayload) -> Observable<AddPromoAPIAtCheckOutResponsePayload> {
        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/listings/\(offerId)/promo_codes")!

        let result = Observable.create {
            (observer: AnyObserver<AddPromoAPIAtCheckOutResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<AddPromoAPIAtCheckOutResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }

    func addPromo(withRequestPayload requestPayload: AddPromoAPIRequestPayload) -> Observable<AddPromoAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/promo_codes")!

        let result = Observable.create {
            (observer: AnyObserver<AddPromoAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<AddPromoAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct AddPromoAPIResponsePayload {
        let promos: [Promo]?

        init(promos: [Promo]?) {
            self.promos = promos
        }
}

extension AddPromoAPIResponsePayload: Serializable {

    static func serialize(jsonRepresentation: AnyObject?) -> AddPromoAPIResponsePayload? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize (copy from the object being serilized)
        var promos: [Promo]?

        // Properties initialization
        if let value = json["promo_codes"] as? [AnyObject] {
            for promoRepresentation in value {
                if let promo = Promo.serialize(promoRepresentation) {
                    promos == nil ? promos = [promo] : promos!.append(promo)
                }
            }
        }
        if let promos = promos {
            let result = AddPromoAPIResponsePayload(promos: promos)
            return result
        }

        return nil
    }
}

struct AddPromoAPIAtCheckOutResponsePayload {
    let pricingBySlots: [PurchaseDetails]

    init (pricingBySlots: [PurchaseDetails]) {
        self.pricingBySlots = pricingBySlots
    }
}

extension AddPromoAPIAtCheckOutResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> AddPromoAPIAtCheckOutResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }
        var pricingBySlots = [PurchaseDetails]()
        if let values = json["pricing_by_slots"] as? [AnyObject] {
            for pricingRepresentation in values {
                if let detail = PurchaseDetails.serialize(pricingRepresentation) {
                    pricingBySlots.append(detail)
                }
            }
        }
        return AddPromoAPIAtCheckOutResponsePayload(pricingBySlots: pricingBySlots)
    }
}
