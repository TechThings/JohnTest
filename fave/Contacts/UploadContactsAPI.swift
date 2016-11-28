//
//  UploadContactsAPI.swift
//  FAVE
//
//  Created by Nazih Shoura on 09/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct UploadContactsAPIRequestPayload {
    let contactsNumbers: [String]

    init(
        contactsNumbers: [String]
        ) {
        self.contactsNumbers = contactsNumbers
    }
}

extension UploadContactsAPIRequestPayload: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["numbers"] = contactsNumbers

        return parameters
    }
}

protocol UploadContactsAPI {
    func uploadContacts(withRequestPayload requestPayload: UploadContactsAPIRequestPayload) -> Observable<UploadContactsAPIResponsePayload>
}

final class UploadContactsAPIMock: UploadContactsAPI {
    func uploadContacts(withRequestPayload requestPayload: UploadContactsAPIRequestPayload) -> Observable<UploadContactsAPIResponsePayload> {
        let validatedContacts: [String: [String: AnyObject]] = [
            "+601128809324" : ["user_id" : 160424]
            , "0123345545" : ["user_id" : NSNull()]
            , "123456" : ["user_id" : NSNull()]
        ]
        let uploadContactsAPIResponsePayload = UploadContactsAPIResponsePayload(validatedContacts: validatedContacts)
        return Observable.of(uploadContactsAPIResponsePayload)
    }
}
final class UploadContactsAPIDefault: UploadContactsAPI {

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

    func uploadContacts(withRequestPayload requestPayload: UploadContactsAPIRequestPayload) -> Observable<UploadContactsAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/contacts/validate")!

        let result = Observable.create {
            (observer: AnyObserver<UploadContactsAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
                .URLRequest(method: .POST, URL: URL, parameters: parameters, encoding: .URL, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<UploadContactsAPIResponsePayload, NSError>) -> Void in
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

struct UploadContactsAPIResponsePayload {
    let validatedContacts: [String: [String: AnyObject]]

    init(validatedContacts: [String: [String: AnyObject]]) {
        self.validatedContacts = validatedContacts
    }
}

extension UploadContactsAPIResponsePayload: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> UploadContactsAPIResponsePayload? {

        guard let json = jsonRepresentation as? [String: [String: AnyObject]] else {
            return nil
        }

        let result = UploadContactsAPIResponsePayload(validatedContacts: json)

        return result
    }
}
