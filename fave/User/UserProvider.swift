//
//  UserProvider.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol UserProvider: Cachable {
    var currentUser: Variable<User> {get}
    func register(userWithName name: String, email: String, promoCode: String) -> Observable<RegisterUserAPIResponsePayload>
    func verifyPhoneNumber(withCode code: String, requestId: String) -> Observable<VerifyPhoneNumberAPIResponsePayload>
    func phoneNumberVerificationCode(forPhoneNumber phoneNumber: String) -> Observable<PhoneNumberVerificationCodeAPIResponsePayload>

    func verifyPhoneNumberStaging(withCode code: String, requestId: String) -> Observable<VerifyPhoneNumberAPIResponsePayload>
    func phoneNumberVerificationCodeStaging(forPhoneNumber phoneNumber: String) -> Observable<PhoneNumberVerificationCodeAPIResponsePayload>

    func updateProfileRequest(updateSilently: Bool,
                              dateOfBirth: String?,
                              gender: String?,
                              purchaseNotification: Bool?,
                              marketingNotification: Bool?,
                              advertisingId: String?,
                              profileImage: UIImage?)
}

final class UserProviderDefault: Provider, UserProvider {

    // MARK:- Dependancy
    let networkService: NetworkService
    let registerUserAPI: RegisterUserAPI
    let updateProfileAPI: UpdateProfileAPI
    let rxAnalytics: RxAnalytics
    let verifyPhoneNumberAPI: VerifyPhoneNumberAPI
    let phoneNumberVerificationCodeAPI: PhoneNumberVerificationCodeAPI
    let cityProvider: CityProvider

    // Provider variable
    let currentUser: Variable<User>

    init(
        networkService: NetworkService = networkServiceDefault
        , registerUserAPI: RegisterUserAPI = RegisterUserAPIDefault()
        , updateProfileAPI: UpdateProfileAPI = UpdateProfileAPIDefault()
        , phoneNumberVerificationCodeAPI: PhoneNumberVerificationCodeAPI = PhoneNumberVerificationCodeAPIDefault()
        , verifyPhoneNumberAPI: VerifyPhoneNumberAPI = VerifyPhoneNumberAPIDefault()
        , rxAnalytics: RxAnalytics = rxAnalyticsDefault
        , cityProvider: CityProvider = cityProviderDefault
        ) {
        self.cityProvider = cityProvider
        self.networkService = networkService
        self.registerUserAPI = registerUserAPI
        self.updateProfileAPI = updateProfileAPI
        self.rxAnalytics = rxAnalytics
        self.phoneNumberVerificationCodeAPI = phoneNumberVerificationCodeAPI
        self.verifyPhoneNumberAPI = verifyPhoneNumberAPI
        let cashedCurrentUser = UserProviderDefault.loadCacheForCurrentUser()
        self.currentUser = Variable(cashedCurrentUser)

        super.init()

        // Cache the currentUser city
        currentUser
            .asObservable()
            .subscribeNext { UserProviderDefault.cache(currentUser: $0) }
            .addDisposableTo(disposeBag)

        // MARK:- Logout
        // Clear the cashe
        app
            .logoutSignal
            .subscribeNext { UserProviderDefault.clearCacheForCurrentUser() }
            .addDisposableTo(disposeBag)

        // Set the user to Guest
        app
            .logoutSignal
            .map { User.guestUser }
            .bindTo(currentUser)
            .addDisposableTo(disposeBag)
    }
}

// MARK:- API
extension UserProviderDefault {
    func register(userWithName name: String, email: String, promoCode: String) -> Observable<RegisterUserAPIResponsePayload> {
        let city = cityProvider.currentCity.value
        let citySlug = city?.slug

        let registerUserAPIRequestPayload = RegisterUserAPIRequestPayload(name: name, email: email, promoCode: promoCode, citySlug: citySlug)

        let response = registerUserAPI
            .registerUser(withRequestPayload: registerUserAPIRequestPayload)
            .doOnNext { [weak self] (registerUserAPIResponsePayload: RegisterUserAPIResponsePayload) in
                self?.currentUser.value = registerUserAPIResponsePayload.user
                self?.rxAnalytics.identifyUser(UserAttributes(user: registerUserAPIResponsePayload.user, city: city))
        }

        return response
    }

    func verifyPhoneNumber(withCode code: String, requestId: String) -> Observable<VerifyPhoneNumberAPIResponsePayload> {

        let requestPayload = VerifyPhoneNumberAPIRequestPayload(requestId: requestId, code: code)

        let response = verifyPhoneNumberAPI
            .verifyPhoneNumber(withRequestPayload: requestPayload)
            .doOnNext { [weak self] (verifyPhoneNumberAPIResponsePayload: VerifyPhoneNumberAPIResponsePayload) in
                self?.currentUser.value = verifyPhoneNumberAPIResponsePayload.user
                let analyticsModel = UserAnalyticsModel(user: verifyPhoneNumberAPIResponsePayload.user)
                if let _ = verifyPhoneNumberAPIResponsePayload.user.name, let _ = verifyPhoneNumberAPIResponsePayload.user.email {
                    analyticsModel.loginSuccessfulEvent.send()
                    // We don't know the city at this point yet
                    self?.rxAnalytics.identifyUser(UserAttributes(user: verifyPhoneNumberAPIResponsePayload.user, city: nil))
                } else {
                    analyticsModel.signupSuccessfulEvent.send()
                }
        }

        return response
    }

    func verifyPhoneNumberStaging(withCode code: String, requestId: String) -> Observable<VerifyPhoneNumberAPIResponsePayload> {

        let requestPayload = VerifyPhoneNumberAPIRequestPayload(requestId: requestId, code: code)

        let response = VerifyPhoneNumberStagingAPI()
            .verifyPhoneNumber(withRequestPayload: requestPayload)
            .doOnNext { [weak self] (verifyPhoneNumberAPIResponsePayload: VerifyPhoneNumberAPIResponsePayload) in
                self?.currentUser.value = verifyPhoneNumberAPIResponsePayload.user
                let analyticsModel = UserAnalyticsModel(user: verifyPhoneNumberAPIResponsePayload.user)
                if let _ = verifyPhoneNumberAPIResponsePayload.user.name, let _ = verifyPhoneNumberAPIResponsePayload.user.email {
                    analyticsModel.loginSuccessfulEvent.send()
                    // We don't know the city at this point yet
                    self?.rxAnalytics.identifyUser(UserAttributes(user: verifyPhoneNumberAPIResponsePayload.user, city: nil))
                } else {
                    analyticsModel.signupSuccessfulEvent.send()
                }
        }

        return response
    }

    func phoneNumberVerificationCode(forPhoneNumber phoneNumber: String) -> Observable<PhoneNumberVerificationCodeAPIResponsePayload> {
        let requestPayload = PhoneNumberVerificationCodeAPIRequestPayload(phoneNumber: phoneNumber)

        let response = phoneNumberVerificationCodeAPI
            .phoneNumberVerificationCode(withRequestPayload: requestPayload)

        return response
    }

    func phoneNumberVerificationCodeStaging(forPhoneNumber phoneNumber: String) -> Observable<PhoneNumberVerificationCodeAPIResponsePayload> {
        let requestPayload = PhoneNumberVerificationCodeAPIRequestPayload(phoneNumber: phoneNumber)

        let response = PhoneNumberVerificationCodeStagingAPI()
            .phoneNumberVerificationCode(withRequestPayload: requestPayload)

        return response
    }

    func updateProfileRequest(updateSilently: Bool,
                              dateOfBirth: String?,
                              gender: String?,
                              purchaseNotification: Bool?,
                              marketingNotification: Bool?,
                              advertisingId: String?,
                              profileImage: UIImage?) {

        let updateProfileAPIRequestPayload = UpdateProfileAPIRequestPayload(
            dateOfBirth: dateOfBirth,
            gender: gender,
            purchaseNotification: purchaseNotification,
            marketingNotification: marketingNotification,
            advertisingId: advertisingId,
            profileImage: profileImage)

        var updateRequest = updateProfileAPI.updateProfile(withRequestPayload: updateProfileAPIRequestPayload)

        if (!updateSilently) {
            updateRequest = updateRequest.trackActivity(app.activityIndicator)
        }

        updateRequest
//            .doOnError {
//                [weak self] in
//                if (!updateSilently) {
//                    self?.wireframeService.alertFor($0, actions: nil)
//                }
//            }
            .map {
                $0.user
            }
            .bindTo(currentUser)
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Cashe
extension UserProviderDefault {
    static func clearCacheForCurrentUser() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                nil, forKey: "\(String(UserProviderDefault)).currentUser")
    }

    static func cache(currentUser user: User) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(user)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: String("\(String(UserProviderDefault)).currentUser"))
    }

    static func loadCacheForCurrentUser() -> User {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(String(UserProviderDefault)).currentUser") as? NSData else {
            return User.guestUser
        }

        guard let user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? User else {
            UserProviderDefault.clearCacheForCurrentUser()
            return User.guestUser
        }
        return user
    }
}
