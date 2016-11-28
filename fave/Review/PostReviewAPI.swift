//
//  PostReviewAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 8/12/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct PostReviewAPIRequestPayload {
    let reservation_id: Int
    let comment: String
    let rating: Float

    init(
        reservation_id: Int
        , comment: String
        , rating: Float
        ) {
        self.reservation_id = reservation_id
        self.comment = comment
        self.rating = rating
    }
}

extension PostReviewAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        var review = [String: AnyObject]()
        review["reservation_id"] = reservation_id
        review["comment"] = comment
        review["rating"] = rating
        parameters["review"] = review

        return parameters
    }
}

protocol PostReviewAPI {
    func postReview(withRequestPayload requestPayload: PostReviewAPIRequestPayload) -> Observable<PostReviewAPIResponsePayload>
}

final class PostReviewAPIDefault: PostReviewAPI {

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

    func postReview(withRequestPayload requestPayload: PostReviewAPIRequestPayload) -> Observable<PostReviewAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/reviews")!

        let result = Observable.create {
            (observer: AnyObserver<PostReviewAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .JSON, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<PostReviewAPIResponsePayload, NSError>) -> Void in
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

struct PostReviewAPIResponsePayload {
    let review: Review
    init(review: Review) {
        self.review = review
    }
}

extension PostReviewAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> PostReviewAPIResponsePayload? {
        guard let review = Review.serialize(jsonRepresentation) else {return nil}
        return PostReviewAPIResponsePayload(review: review)
    }
}
