//
//  CompanyAPI.swift
//  FAVE
//
//  Created by Thanh KFit on 8/2/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct CompanyAPIRequestPayload {
    let companyId: Int

    init(
        companyId: Int
        ) {
        self.companyId = companyId
    }
}

extension CompanyAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        let parameters = [String: AnyObject]()
        return parameters
    }
}

protocol CompanyAPI {
    func getCompany(withRequestPayload requestPayload: CompanyAPIRequestPayload) -> Observable<CompanyAPIResponsePayload>
}

final class CompanyAPIDefault: CompanyAPI {

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

    func getCompany(withRequestPayload requestPayload: CompanyAPIRequestPayload) -> Observable<CompanyAPIResponsePayload> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/cities/\(citySlug)/companies/\(requestPayload.companyId)")!

        let result = Observable.create {
            (observer: AnyObserver<CompanyAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .GET, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<CompanyAPIResponsePayload, NSError>) -> Void in
                if let value = response.result.value { observer.on(.Next(value)) }
                if let error = response.result.error { observer.on(.Error(error)) }
                observer.on(.Completed)
            }
            return AnonymousDisposable { request.cancel() }
        }
        return result
    }
}

struct CompanyAPIResponsePayload {
    let company: Company

    init(company: Company) {
        self.company = company
    }
}

extension CompanyAPIResponsePayload: Serializable {
    typealias Type = CompanyAPIResponsePayload
    static func serialize(jsonRepresentation: AnyObject?) -> CompanyAPIResponsePayload? {
        guard let json = jsonRepresentation?["company"] as? [String : AnyObject] else {
            return nil
        }
        guard let company = Company.serialize(json) else {return nil}
        let result = CompanyAPIResponsePayload(company: company)
        return result
    }
}
