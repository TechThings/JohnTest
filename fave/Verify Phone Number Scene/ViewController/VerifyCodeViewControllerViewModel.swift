//
//  VerifyCodeViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  VerifyCodeViewControllerViewModel
 */
final class VerifyCodeViewControllerViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    let userProvider: UserProvider
    let locationService: LocationService
    let cityProvider: CityProvider

    let code: Variable<String>

    //MARK:- Input

    let resendButtonDidTap = PublishSubject<Void>()
    let submitButtonDidTap = PublishSubject<Void>()
    let submitButtonDidLogPress = PublishSubject<Void>()
    let requestId: String

    init(
        userProvider: UserProvider = userProviderDefault
        , requestId: String
        , locationService: LocationService = locationServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.locationService = locationService
        self.cityProvider = cityProvider

        self.requestId = requestId
        self.userProvider = userProvider
        self.code = Variable("")
        super.init()

        submitButtonDidTap
            .subscribeNext { [weak self] _ in
                self?.verifyPhoneNumber()
            }.addDisposableTo(disposeBag)

        submitButtonDidLogPress.subscribeNext { [weak self] _ in
            self?.verifyPhoneNumberStaging()
            }.addDisposableTo(disposeBag)

        resendButtonDidTap
            .subscribeNext { [weak self] _ in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    viewController.navigationController?.popViewControllerAnimated(true)
                }
            }.addDisposableTo(disposeBag)
    }

    func verifyPhoneNumber() {
        let request = self.userProvider.verifyPhoneNumber(withCode: code.value, requestId: self.requestId)

        request
            .trackActivity(app.activityIndicator)
            .trackActivity(activityIndicator)
            .doOnError { (error: ErrorType) in
                self.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error), animated: true, completion: nil)
                })
            }
            .subscribeNext { [weak self] (verifyPhoneNumberAPIResponsePayload: VerifyPhoneNumberAPIResponsePayload) in
                guard let strongSelf = self else { return }
                strongSelf.lightHouseService.navigate.onNext({ (viewController: UIViewController) in

                    if strongSelf.app.isRegisteredForRemoteNotifications() == false {
                        if strongSelf.app.isCompletedRequestEnableNotification == false {
                            let vc = NotificationPermissionViewController.build(NotificationPermissionViewModel())
                            viewController.navigationController?.setViewControllers([vc], animated: true)
                            return
                        }
                    }

                    if (strongSelf.locationService.isAllowedLocationPermission.value == false) {
                        if strongSelf.app.isCompletedRequestEnableLocation == false {
                            let vc = LocationPermissionViewController.build(LocationPermissionViewModel())
                            viewController.navigationController?.setViewControllers([vc], animated: true)
                            return
                        }
                    }

                    guard strongSelf.cityProvider.currentCity.value != nil else {
                        let vc = CitiesViewController.build(CitiesViewModel())
                        viewController.navigationController?.setViewControllers([vc], animated: true)
                        return
                    }

                    if strongSelf.userProvider.currentUser.value.userStatus == UserStatus.Authenticated {
                        let vc = RegisterViewController.build(RegisterViewModel())
                        viewController.navigationController?.setViewControllers([vc], animated: true)
                        return
                    }

                    guard viewController.navigationController?.presentingViewController == nil else {
                        viewController.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                        return
                    }

                    let rootTabBarController = RootTabBarController.build(RootTabBarViewModel(setAsRoot: true))
                    viewController.navigationController?.presentViewController(rootTabBarController, animated: true, completion: nil)
                })
            }.addDisposableTo(disposeBag)
    }

        func verifyPhoneNumberStaging() {
            let request = self.userProvider.verifyPhoneNumberStaging(withCode: code.value, requestId: self.requestId)

            request
                .trackActivity(app.activityIndicator)
                .trackActivity(activityIndicator)
                .doOnError { (error: ErrorType) in
                    self.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                        viewController.presentViewController(UIAlertController.alertController(forError: error), animated: true, completion: nil)
                    })
                }
                .subscribeNext { [weak self] (verifyPhoneNumberAPIResponsePayload: VerifyPhoneNumberAPIResponsePayload) in
                    guard let strongSelf = self else { return }
                    strongSelf.lightHouseService.navigate.onNext({ (viewController: UIViewController) in

                        if strongSelf.app.isRegisteredForRemoteNotifications() == false {
                            if strongSelf.app.isCompletedRequestEnableNotification == false {
                                let vc = NotificationPermissionViewController.build(NotificationPermissionViewModel())
                                viewController.navigationController?.setViewControllers([vc], animated: true)
                                return
                            }
                        }

                        if (strongSelf.locationService.isAllowedLocationPermission.value == false) {
                            if strongSelf.app.isCompletedRequestEnableLocation == false {
                                let vc = LocationPermissionViewController.build(LocationPermissionViewModel())
                                viewController.navigationController?.setViewControllers([vc], animated: true)
                                return
                            }
                        }

                        guard strongSelf.cityProvider.currentCity.value != nil else {
                            let vc = CitiesViewController.build(CitiesViewModel())
                            viewController.navigationController?.setViewControllers([vc], animated: true)
                            return
                        }

                        if strongSelf.userProvider.currentUser.value.userStatus == UserStatus.Authenticated {
                            let vc = RegisterViewController.build(RegisterViewModel())
                            viewController.navigationController?.setViewControllers([vc], animated: true)
                            return
                        }

                        guard viewController.navigationController?.presentingViewController == nil else {
                            viewController.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                            return
                        }

                        let rootTabBarController = RootTabBarController.build(RootTabBarViewModel(setAsRoot: true))
                        viewController.navigationController?.presentViewController(rootTabBarController, animated: true, completion: nil)
                    })
                }.addDisposableTo(disposeBag)

    }
}
