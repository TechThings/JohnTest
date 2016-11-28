//
//  OutletGGMapsSearchAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 6/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol OutletsGGMapsSearchAPI {
    func searchGGMapsOutlet(requestPayload requestPayload: OutletGGMapsSearchRequestPayload) -> Observable<OutletGGMapsSearchResponsePayload>
}

final class OutletsGGMapSearchAPIDefault: OutletsGGMapsSearchAPI {

    let networkService: NetworkService

    init(networkService: NetworkService = networkServiceDefault) {
        self.networkService = networkService
    }

    func searchGGMapsOutlet(requestPayload requestPayload: OutletGGMapsSearchRequestPayload) -> Observable<OutletGGMapsSearchResponsePayload> {

        let URL = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")!

        let result = Observable.create {
            (observer: AnyObserver<OutletGGMapsSearchResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()

            let URLRequest = try! self.networkService
                .URLRequest(
                    method: .GET
                    , URL: URL
                    , parameters: parameters
                    , encoding: .URL
                    , headers: nil
            )

            let request = self.networkService
                .managerWithDefaultConfiguration
                .request(URLRequest)

            request.responseObject {
                (response: Response<OutletGGMapsSearchResponsePayload, NSError>) -> Void in

                if let outletsSearchResponsePayload = response.result.value {
                    observer.onNext(outletsSearchResponsePayload)
                }

                if let error = response.result.error {
                    observer.onError(error)
                }

                observer.onCompleted()
            }

            return AnonymousDisposable {
                request.cancel()
            }
        }

        return result
    }
}
