//
//  PaymentService.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Braintree

/// PaymentService is an proxy adapter for various supported `ServicePayable`
protocol PaymentService {

    // MARK: Supported ServicePayables
    var adyenPaymentFacade: AdyenPaymentFacade { get set }
    var veritransPaymentFacade: VeritransPaymentFacade { get set }
    var braintreePaymentFacade: BraintreePaymentFacade { get set }

    /// this tries to add a payment method by pesenting the UI, and when it gets the result, it will return the primary method, or nil
    func addPaymentMethodFlow(withCardConfiguration configuration: AdyenCardConfiguration?) -> Observable<PaymentMethod?>

    func reserve(withConfiguration configuration: ReservationConfiguration) -> Observable<Reservation>

    func performPayment(withPaymentConfiguration configuration: PayingConfiguration?) -> Observable<()>

    func getSettingsProvider() -> SettingsProvider
}

//MARK: default implementation
extension PaymentService {

    func addPaymentMethodFlow(withCardConfiguration configuration: AdyenCardConfiguration? = nil) -> Observable<PaymentMethod?> {
        var gateway = self.getSettingsProvider().settings.value.paymentGateway

        if let paymentGateway = configuration?.paymentGateway {
            gateway = paymentGateway
        }

        switch gateway {
            case .Adyen:
                return self.adyenPaymentFacade.addPaymentMethod(configuration)
            case .Veritrans:
                return Observable.error(PaymentServiceError.AddPaymentMethodFailed)
            case .Braintree:
                return self.braintreePaymentFacade.addPaymentMethod()
        }

    }

    func reserve(withConfiguration configuration: ReservationConfiguration) -> Observable<Reservation> {

        // 1. determine which payment flow

        switch configuration.paymentGateway {
        case .Adyen:
            return self.adyenPaymentFacade.reserveOffer(configuration)
        case .Veritrans:
            return self.veritransPaymentFacade.reserveOffer(configuration)
        case .Braintree:
            return self.braintreePaymentFacade.reserveOffer(configuration)
        }

    }

    func performPayment(withPaymentConfiguration configuration: PayingConfiguration?) -> Observable<()> {
        var gateway = self.getSettingsProvider().settings.value.paymentGateway
        if let paymentGateway = configuration?.paymentGateway {
            gateway = paymentGateway
        }

        switch gateway {
        case .Adyen:
            return self.adyenPaymentFacade.pay(configuration)
        case .Veritrans:
            return self.veritransPaymentFacade.pay(configuration)
        case .Braintree:
            return self.braintreePaymentFacade.pay(nil)
        }

    }

}

final class PaymentServiceDefault: Provider, PaymentService {
    // MARK:- Dependency
    private let btPaymentClientTokenAPI: BTPaymentClientTokenAPI
    private let addPaymentMethodAPI: AddPaymentMethodAPI
    private let settingsProvider: SettingsProvider
    private let userProvider: UserProvider
    private let paymentMethodsAPI: PaymentMethodsAPI
    private let lightHouseService: LightHouseService
    private let confirmReservationAPI: ConfirmReservationAPI

    // MARK: ServicePayables
    internal var adyenPaymentFacade: AdyenPaymentFacade
    internal var veritransPaymentFacade: VeritransPaymentFacade
    internal var braintreePaymentFacade: BraintreePaymentFacade

    // MARK:- Provider variables

    init(
        btPaymentClientTokenAPI: BTPaymentClientTokenAPI = BTPaymentClientTokenAPIDefault()
        , addPaymentMethodAPI: AddPaymentMethodAPI = AddPaymentMethodAPIDefault()
        , settingsProvider: SettingsProvider = settingsProviderDefault
        , userProvider: UserProvider = userProviderDefault
        , app: AppType = appDefault
        , paymentMethodsAPI: PaymentMethodsAPI = PaymentMethodsAPIDefault()
        , lightHouseService: LightHouseService = lightHouseServiceDefault
        , confirmReservationAPI: ConfirmReservationAPI = ConfirmReservationAPIDefault()
        ) {
        self.lightHouseService = lightHouseService
        self.settingsProvider = settingsProvider
        self.addPaymentMethodAPI = addPaymentMethodAPI
        self.btPaymentClientTokenAPI = btPaymentClientTokenAPI
        self.userProvider = userProvider
        self.paymentMethodsAPI = paymentMethodsAPI
        self.confirmReservationAPI = confirmReservationAPI

        self.adyenPaymentFacade = AdyenPaymentFacade(lighthouseService: self.lightHouseService, addPaymentMethodAPI: addPaymentMethodAPI, app: app, paymentMethodsAPI: self.paymentMethodsAPI)

        self.veritransPaymentFacade = VeritransPaymentFacade(userProvider: self.userProvider, lighthouseService: self.lightHouseService, confirmReservationAPI: self.confirmReservationAPI)

        self.braintreePaymentFacade = BraintreePaymentFacade(lighthouseService: self.lightHouseService, addPaymentMethodAPI: self.addPaymentMethodAPI, paymentMethodsAPI: self.paymentMethodsAPI, confirmReservationAPI: self.confirmReservationAPI, btPaymentClientTokenAPI: btPaymentClientTokenAPI)
        super.init()

    }

    func getSettingsProvider() -> SettingsProvider {
        return self.settingsProvider
    }

}

enum PaymentServiceError: DescribableError {
    case AddPaymentMethodCancelled
    case AddPaymentMethodFailed
    case NoPrimaryMethod
    case BTAPIClientCouldNotBeInitilized
    case CVCRequired(forPaymentMethod: PaymentMethod)

    var description: String {
        switch self {
        case .AddPaymentMethodCancelled:
            return "Add Payment Method Cancelled"
        case .AddPaymentMethodFailed:
            return "Add Payment Method Failed"
        case .NoPrimaryMethod:
            return "No Primary"
        case .BTAPIClientCouldNotBeInitilized:
            return "BT API Client Could Not Be Initilized"
        default: return ""
        }
    }

    var userVisibleDescription: String {
        switch self {
        case .AddPaymentMethodCancelled:
            return NSLocalizedString("msg_something_wrong", comment: "")
        case .AddPaymentMethodFailed:
            return NSLocalizedString("msg_something_wrong", comment: "")
        case .NoPrimaryMethod:
            return NSLocalizedString("msg_something_wrong", comment: "")
        case .BTAPIClientCouldNotBeInitilized:
            return NSLocalizedString("msg_something_wrong", comment: "")
        case .CVCRequired:
            return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }

}
