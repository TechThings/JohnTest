//
//  RegisterViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Validator

final class RegisterViewModel: ViewModel {

    // Tracking Screen
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    private let registerUserAPI: RegisterUserAPI
    private let validationService: ValidationService
    private let userProvider: UserProvider
    private let addPromoAPI: AddPromoAPI
    let locationService: LocationService
    let cityProvider: CityProvider

    // MARK:- Input
    let name: Variable<String> = Variable("")
    let email: Variable<String> = Variable("")
    let promoCode: Variable<String> = Variable("")

    // MARK- Output
    let everythingValid: Driver<Bool>
    let nameInputErrorMessage: Driver<String>
    let nameInputBoarderColor: Driver<CGColor>
    let nameLabelColor: Driver<UIColor>
    let emailInputErrorMessage: Driver<String>
    let emailLabelColor: Driver<UIColor>
    let emailInputBoarderColor: Driver<CGColor>

    init(
        registerUserAPI: RegisterUserAPI = RegisterUserAPIDefault()
        , validationService: ValidationService = ValidationServiceDefault()
        , userProvider: UserProvider = userProviderDefault
        , addPromoAPI: AddPromoAPI = AddPromoAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        //  Dependency
        self.registerUserAPI = registerUserAPI
        self.validationService = validationService
        self.userProvider = userProvider
        self.locationService = locationService
        self.cityProvider = cityProvider
        self.addPromoAPI = addPromoAPI

        let nameIsValid = name
            .asObservable()
            .skip(1)
            .map { (name: String) -> Bool in name.characters.count > 0 }

        let emailIsValid = email
            .asObservable()
            .skip(1)
            .map { (email: String) -> Bool in validationService.validateEmail(email) == .Valid }

        everythingValid = Observable
            .combineLatest(nameIsValid, emailIsValid) { (nameIsValid: Bool, emailIsValid: Bool) in
                return (nameIsValid && emailIsValid)
            }
            .asDriver(onErrorJustReturn: false)

        nameInputErrorMessage = nameIsValid
            .map { (nameIsValid: Bool) in nameIsValid ? "" : NSLocalizedString("name-error", comment: "") }.asDriver(onErrorJustReturn: "")
        emailInputErrorMessage = emailIsValid
            .map { (emailIsValid: Bool) in emailIsValid ? "" : NSLocalizedString("email-error", comment: "") }.asDriver(onErrorJustReturn: "")

        nameLabelColor = nameInputErrorMessage
            .map { (nameInputErrorMessage: String) -> UIColor in
            nameInputErrorMessage == ""
                ? UIColor.blackColor()
                : UIColor.redColor()}

        emailLabelColor = emailInputErrorMessage
            .map { (emailInputErrorMessage: String) -> UIColor in
                emailInputErrorMessage == ""
                    ? UIColor.blackColor()
                    : UIColor.redColor()}

        nameInputBoarderColor = nameInputErrorMessage
            .map { (nameInputErrorMessage: String) -> CGColor in
            nameInputErrorMessage == ""
                ? UIColor.lightGrayColor().CGColor
                : UIColor.redColor().CGColor }

        emailInputBoarderColor = emailInputErrorMessage
            .map { (emailInputErrorMessage: String) -> CGColor in
            emailInputErrorMessage == ""
                ? UIColor.lightGrayColor().CGColor
                : UIColor.redColor().CGColor }

        super.init()
    }

    func requestAddPromoRegiseterUser() {
        if promoCode.value.isEmpty {
            regiseterUser()
        } else {
            addPromoCode(promoCode.value)
                .subscribe(
                    onNext: { [weak self] _ in
                        self?.regiseterUser()
                    }
                    , onError: {  [weak self] (error: ErrorType) in
                        self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                            viewController.presentViewController(viewController, animated: true, completion: nil)
                        }
                    }
                ).addDisposableTo(disposeBag)

        }

    }

    private func addPromoCode(code: String) -> Observable<AddPromoAPIResponsePayload> {
        let addPromoAPIObservable = addPromoAPI
            .addPromo(withRequestPayload: AddPromoAPIRequestPayload(code: code))
        return addPromoAPIObservable
    }

    private func regiseterUser() {
        userProvider
            .register(userWithName: name.value, email: email.value, promoCode: promoCode.value)
            .trackActivity(app.activityIndicator)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                        guard viewController.navigationController?.presentingViewController == nil else {
                            viewController.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                            return
                        }
                        let rootTabBarController = RootTabBarController.build(RootTabBarViewModel(setAsRoot: true))
                        viewController.navigationController?.presentViewController(rootTabBarController, animated: true, completion: nil)
                    }

                }, onError: {  [weak self] (error: ErrorType) in
                    self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                        let alertViewController = UIAlertController.alertController(forError: error)
                        viewController.presentViewController(alertViewController, animated: true, completion: nil)
                    }
                }
            )
            .addDisposableTo(disposeBag)
    }
}
