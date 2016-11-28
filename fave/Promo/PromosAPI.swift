//
//  PromosAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct PromosAPIRequestPayload {

    init(

        ) {
    }
}

extension PromosAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()

        return parameters
    }
}

protocol PromosAPI {
    func promos(withRequestPayload requestPayload: PromosAPIRequestPayload) -> Observable<PromosAPIResponsePayload>
}

final class PromosAPIDefault: PromosAPI {

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

    func promos(withRequestPayload requestPayload: PromosAPIRequestPayload) -> Observable<PromosAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/promo_codes")!

        let result = Observable.create {
            (observer: AnyObserver<PromosAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<PromosAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct PromosAPIResponsePayload {
        let promos: [Promo]
        let numberOfTotalPromos: Int

        init(promos: [Promo], numberOfTotalPromos: Int) {
            self.promos = promos
            self.numberOfTotalPromos = numberOfTotalPromos
        }
}

extension PromosAPIResponsePayload: Serializable {

        static func serialize(jsonRepresentation: AnyObject?) -> PromosAPIResponsePayload? {

            guard let json = jsonRepresentation as? [String : AnyObject] else {
                return nil
            }

            // Properties to initialize (copy from the object being serilized)
            var promos = [Promo]()
            var numberOfTotalPromos: Int!

            // Properties initialization
            if let value = json["promo_codes"] as? [AnyObject] {
                for promoRepresentation in value {
                    if let promo = Promo.serialize(promoRepresentation) {
                        promos.append(promo)
                    }
                }
            }

            if let value = json["meta"]?["results"] as? Int {
                numberOfTotalPromos = value
            }

            // Verify properties and initialize object
            if let numberOfTotalPromos = numberOfTotalPromos {
                let result = PromosAPIResponsePayload(promos: promos, numberOfTotalPromos: numberOfTotalPromos)
                return result
            }
            return nil
        }
}
