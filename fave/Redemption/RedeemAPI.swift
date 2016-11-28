//
//  RedeemAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct RedeemAPIRequestPayload {
    let redemptionIntent: [(code: String, currentDateTime: NSDate, outletId: Int?)]

    init(redemptionIntent: [(code: String, currentDateTime: NSDate, outletId: Int?)]) {
        self.redemptionIntent = redemptionIntent
    }
}

extension RedeemAPIRequestPayload: Deserializable {
    func deserialize() -> [String:AnyObject] {
        var redemptions = [[String: AnyObject]]()
        for redemptionIntent in self.redemptionIntent {
            if let outletId = redemptionIntent.outletId {
                let redemption = ["code": redemptionIntent.code,
                                  "device_datetime": redemptionIntent.currentDateTime.RFC3339DateTimeString,
                                  "outlet_id": outletId]
                    as [String:AnyObject]
                redemptions.append(redemption)
            } else {
                let redemption = ["code": redemptionIntent.code,
                                  "device_datetime": redemptionIntent.currentDateTime.RFC3339DateTimeString]
                    as [String:AnyObject]
                redemptions.append(redemption)
            }
        }

        var parameters = [String: AnyObject]()

        parameters["redemptions"] = redemptions
        parameters["background"] = false
        return parameters
    }
}

protocol RedeemAPI {
    func redeem(withRequestPayload requestPayload: RedeemAPIRequestPayload) -> Observable<RedeemAPIResponsePayload>
}

final class RedeemAPIDefault: RedeemAPI {

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

    func redeem(withRequestPayload requestPayload: RedeemAPIRequestPayload) -> Observable<RedeemAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/redemptions")!

        let result = Observable.create {
            (observer: AnyObserver<RedeemAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .JSON, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<RedeemAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct RedeemAPIResponsePayload {
    let redemptions: [Redemption]

    init(redemptions: [Redemption]) {
        self.redemptions = redemptions
    }
}

extension RedeemAPIResponsePayload: Serializable {
    typealias Type = RedeemAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> RedeemAPIResponsePayload? {
        guard let json = jsonRepresentation?["results"] as? [AnyObject] else {
            return nil
        }

        guard let redemptions = { () -> [Redemption]? in
            var redemptions = [Redemption]()
            // Transform the received value
            for representation in json {
                guard let redemption = Redemption.serialize(representation) else { return nil}
                redemptions.append(redemption)
            }
            if redemptions.isEmpty {
                return nil
            }
            return redemptions
            }() else {return nil}
        let result = RedeemAPIResponsePayload(redemptions: redemptions)

        return result
    }
}
