//
//  AddCrowdSourceOutletAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 02/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct AddCrowdSourceOutletAPIRequestPayload {
    let outlet: OutletGGMapsSearch

    init (outlet: OutletGGMapsSearch) {
        self.outlet = outlet
    }
}

extension AddCrowdSourceOutletAPIRequestPayload : Deserializable {
    func deserialize() -> [String : AnyObject] {
        var parameter = [String : AnyObject]()

        parameter["favorite"] = true
        parameter["data_source"] = "google"
        parameter["data"] = outlet.dataJson
        return parameter
    }
}

protocol AddCrowdSourceOutletAPI {
    func addCrowdSourceOutlet(withRequestPayload requestPayload: AddCrowdSourceOutletAPIRequestPayload) -> Observable<AddCrowdSourceOutletAPIResponsePayload>
}

final class AddCrowdSourceOutletAPIDefault: AddCrowdSourceOutletAPI {

    let apiService: APIService
    let networkService: NetworkService
    let cityProvider: CityProvider

    init(apiService: APIService = apiServiceDefault
        , networkService: NetworkService = networkServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        ) {
        self.apiService = apiService
        self.networkService = networkService
        self.cityProvider = cityProvider
    }

    func addCrowdSourceOutlet(withRequestPayload requestPayload: AddCrowdSourceOutletAPIRequestPayload) -> Observable<AddCrowdSourceOutletAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/companies/crowdsource")!

        let result = Observable.create {
            (observer: AnyObserver<AddCrowdSourceOutletAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .JSON, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<AddCrowdSourceOutletAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct AddCrowdSourceOutletAPIResponsePayload {
    let success: Bool

    init(success: Bool) {
        self.success = success
    }
}

extension AddCrowdSourceOutletAPIResponsePayload: Serializable {
    typealias Type = AddCrowdSourceOutletAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> AddCrowdSourceOutletAPIResponsePayload? {
        return AddCrowdSourceOutletAPIResponsePayload(success: true)
    }
}
