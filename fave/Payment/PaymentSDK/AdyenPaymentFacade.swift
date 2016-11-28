//
//  AdyenServicePayable.swift
//  FAVE
//
//  Created by Light Dream on 13/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import AdyenCheckout

final class AdyenPaymentFacade: PaymentFacadeType {

    private let addPaymentMethodResult: PublishSubject<PaymentMethod?> = PublishSubject()
    private let performPaymentResult: PublishSubject<()> = PublishSubject()

    // MARK: Dependency
    private let lighthouseService: LightHouseService
    private let app: AppType
    private let paymentMethodsAPI: PaymentMethodsAPI
    private let addPaymentMethodAPI: AddPaymentMethodAPI
    private let confirmReservationAPI: ConfirmReservationAPI

    init(lighthouseService: LightHouseService = lightHouseServiceDefault, addPaymentMethodAPI: AddPaymentMethodAPI = AddPaymentMethodAPIDefault(), app: AppType = appDefault, paymentMethodsAPI: PaymentMethodsAPI = PaymentMethodsAPIDefault(), confirmReservationAPI: ConfirmReservationAPI = ConfirmReservationAPIDefault()) {

        self.lighthouseService = lighthouseService
        self.addPaymentMethodAPI = addPaymentMethodAPI
        self.app = app
        self.paymentMethodsAPI = paymentMethodsAPI
        self.confirmReservationAPI = confirmReservationAPI

    }

    // MARK: Protocol implementation
    func addPaymentMethod(configuration: AdyenCardConfiguration?) -> Observable<PaymentMethod?> {
        var observer: Observable<PaymentMethod?>

        if let config = configuration {
            observer = self.addAdyenPaymentMethod(withCardConfiguration: config)
        } else {

            let vcObservable = Observable.of(adyenViewController)

            observer = vcObservable
                .doOnNext { [weak self] (performPaymentViewController: UIViewController) in
                    self?.lighthouseService.navigate.onNext({ (viewController) in
                        viewController.presentViewController(performPaymentViewController, animated: true, completion: nil)
                    })
                }
                .flatMap {
                    [weak self] _ -> Observable<PaymentMethod?> in
                    guard let strongself = self else {
                        throw ConfirmationViewModelError.PaymentFailed
                    }
                    return strongself
                        .addPaymentMethodResult
                        .asObservable()

            }
        }

        return observer
    }

    func reserveOffer(configuration: ReservationConfiguration) -> Observable<Reservation> {

        let request = self
            .paymentMethods()
            // Get the primary payment method
            .map {
                (paymentMethods: [PaymentMethod]) -> PaymentMethod? in
                return paymentMethods.filter({ $0.primary == true }).first
            }
            // If there's no primary payment method, procceed to add payment flow
            .catchOnNil {
                [weak self] _ -> Observable<PaymentMethod> in
                guard let strongself = self else {
                    throw ConfirmationViewModelError.NoPaymentMethod
                }

                return strongself.addPaymentMethod(nil).errorOnNil(ConfirmationViewModelError.NoPaymentMethod)

            }
            .flatMap {
                [weak self] (payment: PaymentMethod) -> Observable<(PaymentMethod, ConfirmReservationAPIResponsePayload)> in
                guard let strongself = self else {
                    return Observable.error(ConfirmationViewModelError.PaymentFailed)
                }

                return strongself.confirmReservationAPI.confirmReservation(withRequestPayload: strongself.confirmReservationAPIRequestPayload(configuration)).map { result -> (PaymentMethod, ConfirmReservationAPIResponsePayload) in
                    return (payment, result)
                }
            }
            .trackActivity(app.activityIndicator)
            .flatMap { [weak self] (paymentMethod: PaymentMethod, response: ConfirmReservationAPIResponsePayload) -> Observable<Reservation> in
                guard let strongSelf = self else {
                    return Observable.error(ConfirmationViewModelError.PaymentFailed)
                }
                switch response.response {
                case .ReservationSuccessfull(let reservation):
                    return Observable.of(reservation)
                case .CVCRequired:
                    throw PaymentServiceError.CVCRequired(forPaymentMethod: paymentMethod)
                case .Adyen3DRequired(let adyen3dsauth):
                    return strongSelf.authenticate3ds(adyen3dsauth).map { (authResult: Adyen3DSAuthenticationResponse) -> Reservation in
                        switch authResult {
                        case .ReservationResponse(let reservation):
                            return reservation
                        default:
                            throw ConfirmationViewModelError.PaymentFailed

                        }
                    }
                }
        }
        return request

    }

    func pay(configuration: PayingConfiguration? = nil) -> Observable<()> {

        let vcObservable = Observable.of(adyenViewController)

        return vcObservable
            .flatMapLatest({ [weak self] (vc: UIViewController) -> Observable<()> in
                guard let strongself = self else {
                    throw (ConfirmationViewModelError.NoPaymentMethod)
                }
                self?.lighthouseService
                    .navigate
                    .onNext({ (viewController) in
                        viewController.presentViewController(vc, animated: true, completion: nil)
                    })
                return strongself.performPaymentResult.asObservable()
            })

    }
}

// MARK: Adyen specific stuff
extension AdyenPaymentFacade {
    var adyenViewController: UIViewController {
        let vm = AddPaymentMethodViewControllerViewModel(resultSubject: self.addPaymentMethodResult, adyenPayment: self)
        let vc = AddPaymentMethodViewController.build(vm)
        let nvc = NavigationController(rootViewController: vc)
        return nvc
    }

    func paymentMethods() -> Observable<[PaymentMethod]> {
        return paymentMethodsAPI
            .paymentsMethods(withRequestPayload: PaymentMethodsAPIRequestPayload())
            .map {
                (responsePayload) -> [PaymentMethod] in
                return responsePayload.paymentMethods
        }
    }

    func addAdyenPaymentMethod(withCardConfiguration configuration: AdyenCardConfiguration) -> Observable<PaymentMethod?> {
        // TODO: Verify the card here
        let cardLast4Digits = configuration.cardNumber[(configuration.cardNumber.characters.count - 1 - 3)...(configuration.cardNumber.characters.count - 1)]
        let cardPaymentData = buildAdyenCardData(withCardHolderName: configuration.cardHolderName, cardNumber: configuration.cardNumber, cvc: configuration.cvc, expiryDate: configuration.expiryDate)

        let encryptedAdyenCardPaymentData = encryptAdyenCardPaymentData(fromCardData: cardPaymentData)

        let result = encryptedAdyenCardPaymentData
            .flatMap { [weak self] (encryptedAdyenCardPaymentData: String) -> Observable<PaymentMethod?> in
                guard let strongSelf = self else { return Observable.error(PaymentServiceError.AddPaymentMethodCancelled) }
                let addPaymentMethodAPIRequestPayload = AddPaymentMethodAPIRequestPayload(nonce: encryptedAdyenCardPaymentData, gateway: PaymentGateway.Adyen.rawValue, cardLast4Digits: cardLast4Digits)
                return strongSelf
                    .addPaymentMethodAPI
                    .addPaymentMethod(withRequestPayload: addPaymentMethodAPIRequestPayload)
                    .flatMap { [weak self]
                        (responsePayload) -> Observable<[PaymentMethod]> in
                        switch responsePayload.response {
                        case .PaymentMethods(let data):
                            return Observable.of(data)
                        case .Adyen3DSRequired(let data):
                            guard let strongSelf = self else {
                                throw PaymentServiceError.AddPaymentMethodFailed
                            }
                            return strongSelf.authenticate3ds(data).map({ (response) -> [PaymentMethod] in
                                switch response {
                                case .PaymentMethods(let data): return data
                                default: throw PaymentServiceError.AddPaymentMethodFailed
                                }
                            })
                        }

                    }
                    .map {
                        (paymentMethods: [PaymentMethod]) -> PaymentMethod? in
                        return paymentMethods.filter({ $0.primary == true }).first
                    }

            }.doOnNext { [weak self] (paymentMethods: PaymentMethod?) in
                self?.addPaymentMethodResult.onNext(paymentMethods)
                self?.addPaymentMethodResult.onCompleted()
            }.doOnError { [weak self] (error: ErrorType) in
                self?.addPaymentMethodResult.onError(error)
        }

        return result
    }

    private func buildAdyenCardData(withCardHolderName cardHolderName: String, cardNumber: String, cvc: String, expiryDate: NSDate) -> CardPaymentData {
        let yearString = String(expiryDate.year)[2...3] // only the last two numbers are needed: 2020 -> 20
        var monthString = String(expiryDate.month)
        if monthString.characters.count == 1 { monthString = "0" + monthString }
        let expirationDate = "\(monthString)/\(yearString)"
        let cardPaymentData = CardPaymentData(number: cardNumber, cvc: cvc, expirationDate: expirationDate, name: cardHolderName)
        return cardPaymentData
    }

    private func encryptAdyenCardPaymentData(fromCardData cardPaymentData: CardPaymentData) -> Observable<String> {
        Checkout.shared.useTestBackend = app.mode.isDebug
        Checkout.shared.token = app.keys.AdyenToken
        let result = fetchAdyenPublickKey()
            .flatMap { (publickKey: String) -> Observable<String> in
                Checkout.shared.publicKey = publickKey
                do {
                    let encryptedData = try cardPaymentData.serialize()
                    return Observable.of(encryptedData)
                } catch let error {
                    return Observable.error(error)
                }
        }

        return result
    }

    private func fetchAdyenPublickKey() -> Observable<String> {
        let result = Observable.create { (observer: AnyObserver<String>) -> Disposable in
            Checkout.shared.fetchPublickKey { (publicKey, error) in
                if let publicKey = publicKey {
                    observer.onNext(publicKey)
                }
                if let error = error {
                    observer.onError(error)
                }
                observer.on(.Completed)
            }
            return AnonymousDisposable {}
        }

        return result
    }

    func authenticate3ds(data: AdyenAuth3DS) -> Observable<Adyen3DSAuthenticationResponse> {

        let viewModel = Adyen3DSAuthenticationViewControllerViewModel(adyenAuthData: data)
        let viewController = Adyen3DSAuthenticationViewController.build(viewModel)

        self.lighthouseService.navigate.onNext { (vc) in
            vc.presentViewController(viewController, animated: true, completion: nil)
        }

        // we do a flat map cause we only wanna resume work on the chain after this side effect is completelly finished.
        return viewModel
            .result
            .asObservable()
            .flatMapLatest({ (response: Adyen3DSAuthenticationResponse) -> Observable<Adyen3DSAuthenticationResponse> in
                return Observable.create { observer in
                    viewController.dismissViewControllerAnimated(true, completion: {
                        observer.onNext(response)
                        observer.onCompleted()
                    })

                    return AnonymousDisposable {

                    }
                }
            }).doOn({ (event) in
                switch event {
                case .Error, .Completed:
                    viewController.dismissViewControllerAnimated(true, completion: nil)
                default: break
                }

            })

    }

}
