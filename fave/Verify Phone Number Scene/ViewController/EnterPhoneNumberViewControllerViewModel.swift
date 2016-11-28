//
//  EnterPhoneNumberViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PhoneNumberKit

enum EnterPhoneNumberViewControllerViewModelFunctionality {
    case LoginANewUser
    case LoginAGuestUser
}

/**
 *  @author Nazih Shoura
 *
 *  EnterPhoneNumberViewControllerViewModel
 */
final class EnterPhoneNumberViewControllerViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    let userProvider: UserProvider

    // MARK:- Variable
    let selectedCountryCode: Variable<CountryPhoneRepresentation>
    let phoneNumber: Variable<String>
    let enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality

    //MARK:- Input
    let selectCountryCodeButtonDidTap = PublishSubject<Void>()
    let verifyButtonDidTap = PublishSubject<Void>()
    let dismissButtonDidTap = PublishSubject<Void>()
    let verifyButtonDidLogPress = PublishSubject<Void>()

    // MARK:- Intermediate

    // MARK- Output
    var countryCode: Driver<String> = Driver.of("")
    var countryCallingCode: Driver<String>  = Driver.of("")
    var countryName: Driver<String>  = Driver.of("Select country code")
    var verifyButtonEnabled: Driver<Bool>  = Driver.of(false)
    var dismissButtonEnabled: Driver<Bool> = Driver.of(false)
    init(
        userProvider: UserProvider = userProviderDefault
        , enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.userProvider = userProvider
        self.enterPhoneNumberViewControllerViewModelFunctionality = enterPhoneNumberViewControllerViewModelFunctionality

        self.phoneNumber = Variable("")

        let selectedCountryCode: CountryPhoneRepresentation = {
            let phoneNumberKit = PhoneNumberKit()
            let coutryCodeByCarrier = phoneNumberKit.defaultRegionCode()
            if let countryNameByCarrier = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: coutryCodeByCarrier)
                , let coutryCallingCodeByCarrier = phoneNumberKit.codeForCountry(coutryCodeByCarrier) {
                return CountryPhoneRepresentation(countryName: countryNameByCarrier, countryCallingCode: String(coutryCallingCodeByCarrier), countryCode: coutryCodeByCarrier)
            } else {
                return CountryPhoneRepresentation(countryName: "", countryCallingCode: "", countryCode: "")
            }
        }()

        self.selectedCountryCode = Variable(selectedCountryCode)

        switch enterPhoneNumberViewControllerViewModelFunctionality {
        case .LoginANewUser:
            self.dismissButtonEnabled = Driver.of(true)

        case .LoginAGuestUser:
            self.dismissButtonEnabled = Driver.of(false)
        }

        super.init()

        self.countryCode = self.selectedCountryCode.asDriver().map({ (countryPhoneRepresentation: CountryPhoneRepresentation) -> String in countryPhoneRepresentation.countryCode})
        self.countryName = self.selectedCountryCode.asDriver().map({ (countryPhoneRepresentation: CountryPhoneRepresentation) -> String in countryPhoneRepresentation.countryName})
        self.countryCallingCode = self.selectedCountryCode.asDriver().map({ (countryPhoneRepresentation: CountryPhoneRepresentation) -> String in             "(+"
            .stringByAppendingString(countryPhoneRepresentation.countryCallingCode)
            .stringByAppendingString(")")})

        self.verifyButtonEnabled = phoneNumber.asDriver().map({ (phoneNumber: String) -> Bool in
            !phoneNumber.isEmpty
        })

        self.dismissButtonDidTap.subscribeNext {  [weak self] _ in

            self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                viewController.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            })
            }.addDisposableTo(disposeBag)

        selectCountryCodeButtonDidTap.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }
            let countriesCodesViewController = CountriesCodesViewController.build(CountriesCodesViewControllerViewModel(selectedCountryCode: strongSelf.selectedCountryCode))
            let nav = RootNavigationController.build(RootNavigationViewModel())
            nav.setViewControllers([countriesCodesViewController], animated: false)
            self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                viewController.presentViewController(nav, animated: true, completion: nil)
            })
            }.addDisposableTo(disposeBag)

        verifyButtonDidTap.subscribeNext { [weak self] _ in
            self?.requestPhoneNumberVerificationCode()
            }
            .addDisposableTo(disposeBag)

        verifyButtonDidLogPress.subscribeNext { [weak self] _ in
            self?.requestPhoneNumberVerificationCodeStaging()
            }
            .addDisposableTo(disposeBag)

    }

    func requestPhoneNumberVerificationCodeStaging() {
        let phoneNumber = "+".stringByAppendingString(selectedCountryCode.value.countryCallingCode).stringByAppendingString(self.phoneNumber.value)
        let request = self.userProvider.phoneNumberVerificationCodeStaging(forPhoneNumber: phoneNumber)
            .doOnError { (error: ErrorType) in
                self.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error), animated: true, completion: nil)
                })
        }

        request
            .trackActivity(app.activityIndicator)
            .trackActivity(activityIndicator)
            .subscribeNext { (result: PhoneNumberVerificationCodeAPIResponsePayload) in
                self.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    let verifyCodeViewController = VerifyCodeViewController.build(VerifyCodeViewControllerViewModel(requestId: result.requestId))
                    viewController.navigationController?.pushViewController(verifyCodeViewController, animated: true)
                })
            }.addDisposableTo(disposeBag)
    }

    func requestPhoneNumberVerificationCode() {
        let phoneNumber = "+".stringByAppendingString(selectedCountryCode.value.countryCallingCode).stringByAppendingString(self.phoneNumber.value)
        let request = self.userProvider.phoneNumberVerificationCode(forPhoneNumber: phoneNumber)
            .doOnError { (error: ErrorType) in
                self.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error), animated: true, completion: nil)
                })
        }

        request
            .trackActivity(app.activityIndicator)
            .trackActivity(activityIndicator)
            .subscribeNext { (result: PhoneNumberVerificationCodeAPIResponsePayload) in
                self.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    let verifyCodeViewController = VerifyCodeViewController.build(VerifyCodeViewControllerViewModel(requestId: result.requestId))
                    viewController.navigationController?.pushViewController(verifyCodeViewController, animated: true)
                })
            }.addDisposableTo(disposeBag)
    }
}
