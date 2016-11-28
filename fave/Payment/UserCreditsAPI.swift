//
//  UserCreditsAPI.swift
//  fave
//
//  Created by Michael Cheah on 7/16/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct UserCreditsAPIRequestPayload {
    init() {
    }
}

extension UserCreditsAPIRequestPayload: Deserializable {
    func deserialize() -> [String:AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol UserCreditsAPI {
    func getBalances(withRequestPayload requestPayload: UserCreditsAPIRequestPayload) -> Observable<UserCreditsAPIResponsePayload>
}

final class UserCreditsAPIDefault: UserCreditsAPI {

    private let apiService: APIService
    private let networkService: NetworkService
    private let cityProvider: CityProvider

    init(apiService: APIService = apiServiceDefault,
         networkService: NetworkService = networkServiceDefault,
         cityProvider: CityProvider = cityProviderDefault) {
        self.apiService = apiService
        self.networkService = networkService
        self.cityProvider = cityProvider
    }

    func getBalances(withRequestPayload requestPayload: UserCreditsAPIRequestPayload) -> Observable<UserCreditsAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/balances")!

        let result = Observable.create {
            (observer: AnyObserver<UserCreditsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
            .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<UserCreditsAPIResponsePayload, NSError>) -> Void in
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

struct UserCreditsAPIResponsePayload {
    let balances: UserCredits

    init(balances: UserCredits) {
        self.balances = balances
    }
}

extension UserCreditsAPIResponsePayload: Serializable {
    typealias Type = UserCreditsAPIResponsePayload

    static func serialize(jsonRepresentation: AnyObject?) -> UserCreditsAPIResponsePayload? {
        guard let json = jsonRepresentation?["balances"] as? [String:AnyObject] else {
            return nil
        }

        guard let balances = {
            return UserCredits.serialize(json)
        }()  else {
            return nil
        }

        let result = UserCreditsAPIResponsePayload(balances: balances)
        return result
    }
}
