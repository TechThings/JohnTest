//
//  VeritransServicePayable.swift
//  FAVE
//
//  Created by Light Dream on 11/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import MidtransKit
import MidtransCoreKit

final class VeritransPaymentFacade: NSObject, PaymentFacadeType {

    let notificationCenterDisposableBag = CompositeDisposable()

    var veritransPaymentVC: UIViewController?

    private var addPaymentMethodResult: PublishSubject<PaymentMethod?> = PublishSubject()
    private var performPaymentResult: PublishSubject<NotifyPaymentFinishedAPIRequestPayload> = PublishSubject()

    // MARK: Dependencies
    private let userProvider: UserProvider
    private let lighthouseService: LightHouseService
    private let confirmReservationAPI: ConfirmReservationAPI
    private let cityProvider: CityProvider
    private let notifyPaymentFinishedAPI: NotifyPaymentFinishedAPI

    init(userProvider: UserProvider, lighthouseService: LightHouseService = lightHouseServiceDefault, confirmReservationAPI: ConfirmReservationAPI = ConfirmReservationAPIDefault(), cityProvider: CityProvider = cityProviderDefault, notifyPaymentFinishedAPI: NotifyPaymentFinishedAPI = NotifyPaymentFinishedAPIDefault()) {
        self.userProvider = userProvider
        self.lighthouseService = lighthouseService
        self.confirmReservationAPI = confirmReservationAPI
        self.cityProvider = cityProvider
        self.notifyPaymentFinishedAPI = notifyPaymentFinishedAPI
    }

    private func setup() {

        self.addPaymentMethodResult = PublishSubject()
        self.performPaymentResult = PublishSubject()
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

        guard let config = configuration else {
            return Observable.error(ConfirmationViewModelError.NoPaymentMethod)
        }
        // before we head down this road, we need to get ready

        self.setup()

        let vcObservable = payWithVeritrans(config)

        return vcObservable
            .flatMap({ [weak self] (vc: UIViewController) -> Observable<NotifyPaymentFinishedAPIRequestPayload> in
                guard let strongself = self else {
                    throw (ConfirmationViewModelError.NoPaymentMethod)
                }
                self?.lighthouseService
                    .navigate
                    .onNext({ (viewController) in
                        viewController.presentViewController(vc, animated: true, completion: nil)
                    })
                return strongself.performPaymentResult
            })
            .flatMapLatest({ request -> Observable<NotifyPaymentFinishedAPIResponsePayload> in
                return self.notifyAPI(request)
            })
            .flatMapLatest({ (response) -> Observable<NotifyPaymentFinishedAPIResponsePayload> in

                let delay = response.refreshInterval / 1000 // convert ms to s
                return Observable.just(response).delaySubscription(delay, scheduler: MainScheduler.instance)
//                return delayedObservable.delaySubscription(delay, scheduler: MainScheduler.instance)
            })
            .map { _ in return }

    }
}

// Veritrans methods
extension VeritransPaymentFacade {

    // this returns Observable<UIViewController>
    private func payWithVeritrans(configuration: PayingConfiguration) -> Observable<UIViewController> {

        guard let citySlug = cityProvider.currentCity.value?.slug else {
            return Observable.error(CityProviderError.CityCouldNotBeObtained)
        }

        let orderId = "\(citySlug)_\(configuration.reservationSetId)"

        let itemDetail = MidtransItemDetail(itemID: orderId,
                                            name: configuration.reservation.listingDetails.name,
                                            price: configuration.reservation.purchaseDetails.totalChargeAmount,
                                            quantity: 1)

        MidtransCreditCardConfig.setPaymentType(MTCreditCardPaymentType.Twoclick, secure: false)

        let address = MidtransAddress(firstName: "KFIT",
                                      lastName: "KFIT",
                                      phone: "+60939133233",
                                      address: "Level 2, Tower 7, Avenue 3, The Horizon, Bangsar South, No. 8, Jalan Kerinchi",
                                      city: "Kuala lumpur",
                                      postalCode: "",
                                      countryCode: "")

        let customerDetail = MidtransCustomerDetails(firstName: "KFIT",
                                                     lastName: "KFIT",
                                                     email: "hello@kfit.com",
                                                     phone: "+60939133233",
                                                     shippingAddress: address,
                                                     billingAddress: address)

        customerDetail.customerIdentifier = "\(userProvider.currentUser.value.id)"

        let transactionDetail = MidtransTransactionDetails(orderID: orderId, andGrossAmount: configuration.reservation.purchaseDetails.totalChargeAmount)

        let observable: Observable<UIViewController> = Observable.create { observer in

            MidtransMerchantClient.shared().requestTransactionTokenWithTransactionDetails(transactionDetail, itemDetails: [itemDetail!], customerDetails: customerDetail, completion: { (response, error) in
                if (response != nil) {

                    let vc = MidtransUIPaymentViewController(token: response!)
                    self.veritransPaymentVC = vc
                    self.registerForMidtransDelegate()
                    observer.onNext(vc!)
                    observer.onCompleted()
                } else {

                    observer.onError(error!)
                }

            })

            return AnonymousDisposable {

            }
        }

        return observable

    }

    func registerForMidtransDelegate() {

        // NOTE: Since we are doing `.take(1)`, it will auto dispose of itself.
        let _ = NSNotificationCenter
            .defaultCenter()
            .rx_notification(TRANSACTION_SUCCESS)
            .take(1)
            .subscribeNext { (notif) in
                debugPrint("transaction success")
                let transactionResult: MidtransTransactionResult = notif.userInfo![TRANSACTION_RESULT_KEY] as! MidtransTransactionResult

                // transactionId will be set later
                let payload = NotifyPaymentFinishedAPIRequestPayload(orderId: transactionResult.orderId, transactionId: transactionResult.transactionId, paymentGateway: PaymentGateway.Veritrans.rawValue)

                self.veritransPaymentVC?.dismissViewControllerAnimated(true, completion: {

                    self.performPaymentResult.onNext(payload)
                    self.performPaymentResult.onCompleted()
                })

            }

        let _ = NSNotificationCenter
            .defaultCenter()
            .rx_notification(TRANSACTION_PENDING)
            .take(1)
            .subscribeNext { (notif) in
                debugPrint("transaction pending")
                let transactionResult: MidtransTransactionResult = notif.userInfo![TRANSACTION_RESULT_KEY] as! MidtransTransactionResult

                // transactionId will be set later
                let payload = NotifyPaymentFinishedAPIRequestPayload(orderId: transactionResult.orderId, transactionId: transactionResult.transactionId, paymentGateway: PaymentGateway.Veritrans.rawValue)

                self.performPaymentResult.onNext(payload)
                self.performPaymentResult.onCompleted()

            }

        let _ = NSNotificationCenter
            .defaultCenter()
            .rx_notification(TRANSACTION_FAILED)
            .take(1)
            .subscribeNext { (notif) in
                debugPrint("transaction failed")
                let error = notif.userInfo![TRANSACTION_ERROR_KEY] as! NSError

                self.performPaymentResult.onError(error)
            }

        let _ = NSNotificationCenter
            .defaultCenter()
            .rx_notification(TRANSACTION_CANCELED)
            .take(1)
            .subscribeNext { (notif) in
                debugPrint("transaction cancelled")
                self.performPaymentResult.onCompleted()
            }
    }

    func notifyAPI(requestPayload: NotifyPaymentFinishedAPIRequestPayload) -> Observable<NotifyPaymentFinishedAPIResponsePayload> {

        return self.notifyPaymentFinishedAPI.notifyPaymentFinish(withRequestPayload: requestPayload)

    }
}
