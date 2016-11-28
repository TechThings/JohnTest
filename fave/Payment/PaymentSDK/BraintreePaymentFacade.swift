//
//  BraintreeServicePayable.swift
//  FAVE
//
//  Created by Light Dream on 12/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Braintree

final class BraintreePaymentFacade: NSObject, PaymentFacadeType {

    private let addPaymentMethodResult: PublishSubject<PaymentMethod?> = PublishSubject()
    private let performPaymentResult: PublishSubject<()> = PublishSubject()

    private let lighthouseService: LightHouseService
    private let paymentMethodsAPI: PaymentMethodsAPI
    private let addPaymentMethodAPI: AddPaymentMethodAPI
    private let confirmReservationAPI: ConfirmReservationAPI
    private let btPaymentClientTokenAPI: BTPaymentClientTokenAPI

    init(lighthouseService: LightHouseService = lightHouseServiceDefault, addPaymentMethodAPI: AddPaymentMethodAPI = AddPaymentMethodAPIDefault(), paymentMethodsAPI: PaymentMethodsAPI = PaymentMethodsAPIDefault(), confirmReservationAPI: ConfirmReservationAPI = ConfirmReservationAPIDefault(), btPaymentClientTokenAPI: BTPaymentClientTokenAPI = BTPaymentClientTokenAPIDefault()) {
        self.lighthouseService = lighthouseService
        self.paymentMethodsAPI = paymentMethodsAPI
        self.confirmReservationAPI = confirmReservationAPI
        self.addPaymentMethodAPI = addPaymentMethodAPI
        self.btPaymentClientTokenAPI = btPaymentClientTokenAPI

    }

    func addPaymentMethod() -> Observable<PaymentMethod?> {

        return btDropInViewController
            .doOnNext { [weak self] (performPaymentViewController: UIViewController) in
                self?.lighthouseService.navigate.onNext({ (viewController) in
                    viewController.presentViewController(performPaymentViewController, animated: true, completion: nil)
                })
            }
            .flatMap {
                [weak self] _ -> Observable<PaymentMethod?> in
                guard let strongself = self else {
                    return Observable.error(ConfirmationViewModelError.PaymentFailed)
                }
                return strongself.addPaymentMethodResult.asObservable()
        }

    }

    func reserveOffer(configuration: ReservationConfiguration) -> Observable<Reservation> {
        return confirmReservationAPI
            .confirmReservation(withRequestPayload: self.confirmReservationAPIRequestPayload(configuration))
            .flatMap { (response: ConfirmReservationAPIResponsePayload) -> Observable<Reservation> in

                switch response.response {
                case .ReservationSuccessfull(let reservation):
                    return Observable.of(reservation)
                // because this is veritrans, we don't check for 3ds auth
                default: return Observable.error(PaymentServiceError.AddPaymentMethodFailed)
                }

            }
            .flatMap { (reservation: Reservation) -> Observable<Reservation> in

                let paymentConfiguration = PayingConfiguration.create(fromReservation: reservation)

                let paymentObserver = self.pay(paymentConfiguration)

                return paymentObserver.map { _ in return reservation }
        }

    }

    func pay(configuration: PayingConfiguration?) -> Observable<()> {
        return btDropInViewController
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

extension BraintreePaymentFacade: BTDropInViewControllerDelegate {

     var btDropInViewController: Observable<UIViewController> {
        return btPaymentClientTokenAPI
            .btPaymentClientToken(withRequestPayload: BTPaymentClientTokenAPIRequestPayload(paymentGateway: PaymentGateway.Braintree.rawValue))
            .map {
                (responsePayload) -> BTAPIClient in
                guard let btAPIClient = BTAPIClient(authorization: responsePayload.token) else {
                    throw PaymentServiceError.BTAPIClientCouldNotBeInitilized
                }

                return btAPIClient
            }
            .map {
                [weak self] (btAPIClient: BTAPIClient) -> UIViewController in
                guard let strongself = self else {
                    throw PaymentServiceError.AddPaymentMethodFailed
                }

                let dropInViewController = BTCompletingDropInViewController(APIClient: btAPIClient, completion: {
                    () -> Void in
                    strongself.addPaymentMethodResult.onError(PaymentServiceError.AddPaymentMethodCancelled)
                })
                dropInViewController.delegate = strongself
                let navigationController = UINavigationController(rootViewController: dropInViewController)
                dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: UIBarButtonSystemItem.Cancel,
                    target: dropInViewController, action: #selector(dropInViewController.viewControllerCancelClicked))

                return navigationController
        }
    }

    func addBTPaymentMethod(usingBTPaymentMethodNonce btPaymentMethodNonce: BTPaymentMethodNonce) {

        var disposable: Disposable?

        let addPaymentMethodAPIRequestPayload = AddPaymentMethodAPIRequestPayload(nonce: btPaymentMethodNonce.nonce, gateway: PaymentGateway.Braintree.rawValue, cardLast4Digits: nil)
        disposable = addPaymentMethodAPI
            .addPaymentMethod(withRequestPayload: addPaymentMethodAPIRequestPayload)
            .map {
                (responsePayload) -> [PaymentMethod] in
                switch responsePayload.response {
                case .PaymentMethods(let data):
                    return data
                default:
                    throw PaymentServiceError.AddPaymentMethodFailed
                }

            }.map {
                (paymentMethods: [PaymentMethod]) -> PaymentMethod? in
                return paymentMethods.filter({ $0.primary == true }).first
            }.doOnNext { [weak self] (paymentMethod: PaymentMethod?) in
                self?.addPaymentMethodResult.onNext(paymentMethod)
            }.doOnError { [weak self] (error: ErrorType) in
                self?.addPaymentMethodResult.onError(error)
            }
            .subscribe { (event) in
                switch event {
                case .Error, .Completed:
                    disposable?.dispose()
                default: break
                }
        }

    }

    // MARK: BTDropInViewControllerDelegate
    @objc func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {

        addBTPaymentMethod(usingBTPaymentMethodNonce: paymentMethodNonce)

        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

    @objc func dropInViewControllerDidCancel(viewController: BTDropInViewController) {

        addPaymentMethodResult.onError(PaymentServiceError.AddPaymentMethodCancelled)
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
