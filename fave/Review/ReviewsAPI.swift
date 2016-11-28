//
//  ReviewsAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct ReviewsAPIRequestPayload {
    let companyId: Int

    init(
        companyId: Int
        ) {
        self.companyId = companyId
    }
}

extension ReviewsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol ReviewsAPI {
    func getReviews(withRequestPayload requestPayload: ReviewsAPIRequestPayload) -> Observable<ReviewsAPIResponsePayload>
}

final class ReviewsAPIDefault: ReviewsAPI {

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

    func getReviews(withRequestPayload requestPayload: ReviewsAPIRequestPayload) -> Observable<ReviewsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/companies/\(requestPayload.companyId)/reviews")!

        let result = Observable.create {
            (observer: AnyObserver<ReviewsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<ReviewsAPIResponsePayload, NSError>) -> Void in
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

struct ReviewsAPIResponsePayload {
    let reviews: [Review]

    init(reviews: [Review]) {
        self.reviews = reviews
    }
}

extension ReviewsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ReviewsAPIResponsePayload? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        var reviews = [Review]()
        if let value = json["reviews"] as? [AnyObject] {
            for representation in value {
                if let review = Review.serialize(representation) {
                    reviews.append(review)
                }
            }
        }

        let result = ReviewsAPIResponsePayload(
            reviews: reviews
        )
        return result
    }
}
