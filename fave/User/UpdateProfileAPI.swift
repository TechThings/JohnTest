////
////  UpdateProfileAPI.swift
////  FAVE
////
////  Created by Nazih Shoura on 07/07/2016.
////  Copyright © 2016 kfit. All rights reserved.
////

import Foundation
import RxSwift
import Alamofire

struct UpdateProfileAPIRequestPayload {

    let dateOfBirth: String?
    let gender: String?
    let purchaseNotification: Bool?
    let marketingNotification: Bool?
    let advertisingId: String?
    let profileImage: UIImage?

    init(dateOfBirth: String?,
         gender: String?,
         purchaseNotification: Bool?,
         marketingNotification: Bool?,
         advertisingId: String?,
         profileImage: UIImage?) {
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.purchaseNotification = purchaseNotification
        self.marketingNotification = marketingNotification
        self.advertisingId = advertisingId
        self.profileImage = profileImage
    }
}

extension UpdateProfileAPIRequestPayload: Deserializable {
    func deserialize() -> [String:AnyObject] {
        var parameters = [String: AnyObject]()
        var userProfile = [String: AnyObject]()

        if let dateOfBirth = dateOfBirth {
            userProfile["date_of_birth"] = dateOfBirth
        }

        if let gender = gender {
            userProfile["gender"] = gender
        }

        if let purchaseNotification = purchaseNotification {
            userProfile["purchase_notification"] = purchaseNotification
        }

        if let marketingNotification = marketingNotification {
            userProfile["marketing_notification"] = marketingNotification
        }

        if let advertisingId = advertisingId {
            userProfile["advertising_id"] = advertisingId
        }

        if let image = profileImage, let imageData = UIImagePNGRepresentation(image) {
            let uploadedImage: String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            userProfile["uploaded_image"] = uploadedImage
        }

        // Add to Root Dictionary
        parameters["user"] = userProfile

        return parameters
    }
}

protocol UpdateProfileAPI {
    func updateProfile(withRequestPayload requestPayload: UpdateProfileAPIRequestPayload) -> Observable<UpdateProfileAPIResponsePayload>
}

final class UpdateProfileAPIDefault: UpdateProfileAPI {

    private let apiService: APIService
    private let networkService: NetworkService

    init(apiService: APIService = apiServiceDefault,
         networkService: NetworkService = networkServiceDefault
    ) {
        self.apiService = apiService
        self.networkService = networkService
    }

    func updateProfile(withRequestPayload requestPayload: UpdateProfileAPIRequestPayload) -> Observable<UpdateProfileAPIResponsePayload> {

        let URL = apiService.baseURL.URLByAppendingPathComponent("/api/fave/v1/users/profile")!

        let result = Observable.create {
            (observer: AnyObserver<UpdateProfileAPIResponsePayload>) -> Disposable in

            let parameters = requestPayload.deserialize()
            let URLRequest = try! self.networkService
            .URLRequest(method: .PUT, URL: URL, parameters: parameters, encoding: .JSON, headers: nil)
            let request = self.networkService.managerWithDefaultConfiguration.request(URLRequest)

            request.responseObject {
                (response: Response<UpdateProfileAPIResponsePayload, NSError>) -> Void in
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

struct UpdateProfileAPIResponsePayload {
    let user: User

    init(user: User) {
        self.user = user
    }
}

extension UpdateProfileAPIResponsePayload: Serializable {
    typealias Type = UpdateProfileAPIResponsePayload

    static func serialize(jsonRepresentation: AnyObject?) -> UpdateProfileAPIResponsePayload? {
        guard let json = jsonRepresentation?["user"] as? [String:AnyObject] else {
            return nil
        }

        guard let user = {
            () -> User? in
            // Transform the received value
            return User.serialize(json)
        }() else {
            return nil
        }

        let result = UpdateProfileAPIResponsePayload(user: user)
        return result
    }
}
