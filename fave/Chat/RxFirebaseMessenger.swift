//
//  RxFirebaseMessenger.swift
//  FAVE
//
//  Created by Michael Cheah on 8/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

protocol RxFirebaseMessenger {
    func connect()

    func registerForRemoteNotifications(deviceToken: NSData)
}

final class RxFirebaseMessengerDefault: NSObject, RxFirebaseMessenger {

    private let createDeviceAPI: CreateDeviceAPI
    private let userProvider: UserProvider

    let disposeBag = DisposeBag()

    init (createDeviceAPI: CreateDeviceAPI = CreateDeviceAPIDefault(),
          userProvider: UserProvider = userProviderDefault) {
        self.createDeviceAPI = createDeviceAPI
        self.userProvider = userProvider

        super.init()
    }

    func connect() {
        Observable.of(cachedInstanceIDToken, instanceIDTokenUpdate).concat()
            .flatMap {
                _ -> Observable<Bool> in
                return self.connectToFCM()
            }
            .subscribeNext {
                (connected: Bool) in
                if (connected) {
                    print("Connected to FCM.")
                } else {
                    print("Unable to connect with FCM.")
                }
            }.addDisposableTo(disposeBag)

        userProvider
            .currentUser
            .asObservable()
            .filter {
                return !$0.isGuest
            }
            .flatMap {
                _ in
                return Observable.of(self.cachedInstanceIDToken, self.instanceIDTokenUpdate).concat()
            }
            .flatMap {
                (token: String) in
                // Need to make sure that this is sent only when the user is logged in
                return self.createDeviceAPI.createDevice(withRequestPayload: CreateDeviceAPIRequestPayload(gcmID: token))
            }
            .subscribeNext {
                (response: CreateDeviceAPIResponsePayload) in
                print("Successfully submitted FCM token to server. Status: \(response.status)")
            }.addDisposableTo(disposeBag)
    }

    private var cachedInstanceIDToken: Observable<String> {
        if let token = FIRInstanceID.instanceID().token() {
            return Observable.just(token)
        }

        return Observable.empty()
    }

    private var instanceIDTokenUpdate: Observable<String> {
        return NSNotificationCenter.defaultCenter()
        .rx_notification(kFIRInstanceIDTokenRefreshNotification)
        .map {
            _ in
            return FIRInstanceID.instanceID().token()
        }
        .filter {
            (token: String?) -> Bool in
            return token != nil
        }
        .map {
            (token: String?) -> String in
            return token!
        }
    }

    func setupConnectionToFCM() {
        NSNotificationCenter.defaultCenter()
        .rx_notification(UIApplicationWillEnterForegroundNotification)
        .flatMap {
            _ in
            return self.connectToFCM()
        }
        .subscribeNext {
            (connected: Bool) in
            if (connected) {
                print("Reconnected to FCM.")
            } else {
                print("Unable to reconnect with FCM.")
            }
        }
        .addDisposableTo(disposeBag)

        NSNotificationCenter.defaultCenter()
        .rx_notification(UIApplicationWillResignActiveNotification)
        .subscribeNext {
            _ in
            FIRMessaging.messaging().disconnect()
        }
        .addDisposableTo(disposeBag)
    }

    private func connectToFCM() -> Observable<Bool> {
        return Observable.create {
            (observer: AnyObserver<Bool>) -> Disposable in
            FIRMessaging.messaging().connectWithCompletion {
                (error: NSError?) in
                if let error = error {
                    observer.on(.Error(error))
                } else {
                    observer.on(.Next(true))
                    observer.on(.Completed)
                }
            }

            return AnonymousDisposable {
            }
        }
    }

    func registerForRemoteNotifications(deviceToken: NSData) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: appDefault.keys.firebaseAPNSTokenType)
    }
}
