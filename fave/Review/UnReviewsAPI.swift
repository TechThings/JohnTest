//
//  UnReviewsAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct UnReviewsAPIRequestPayload {

    init(
        ) {
    }
}

extension UnReviewsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol UnReviewsAPI {
    func unReview(withRequestPayload requestPayload: UnReviewsAPIRequestPayload) -> Observable<UnReviewsAPIResponsePayload>
}

final class UnReviewsAPIDefault: UnReviewsAPI {

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

    func unReview(withRequestPayload requestPayload: UnReviewsAPIRequestPayload) -> Observable<UnReviewsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/reservations/past/unreviewed")!

        let result = Observable.create {
            (observer: AnyObserver<UnReviewsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<UnReviewsAPIResponsePayload, NSError>) -> Void in
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

struct UnReviewsAPIResponsePayload {
    let unReviews: [Reservation]

    init(unReviews: [Reservation]) {
        self.unReviews = unReviews
    }
}

extension UnReviewsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> UnReviewsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        var unReviews = [Reservation]()
        if let value = json["unreviewed"] as? [AnyObject] {
            for representation in value {
                if let unReview = Reservation.serialize(representation) {
                    unReviews.append(unReview)
                }
            }
        }

        let result = UnReviewsAPIResponsePayload(
            unReviews: unReviews
        )
        return result
    }
}
