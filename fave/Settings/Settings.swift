//
//  Settings.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/9/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class Settings: NSObject, NSCoding {

    let paymentGateway: PaymentGateway
    var chatCreditFeature: Bool
    var chatCreditPercentage: Int
    var appCompany: AppCompany

    init(
        paymentGateway: PaymentGateway,
        chatCreditFeature: Bool,
        chatCreditPercentage: Int,
        appCompany: AppCompany
        ) {
        self.paymentGateway         = paymentGateway
        self.chatCreditFeature      = chatCreditFeature
        self.chatCreditPercentage   = chatCreditPercentage
        self.appCompany             = appCompany
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        guard let paymentGateway = { () -> PaymentGateway? in
            guard let paymentGatewayString = aDecoder.decodeObjectForKey("\(literal.Settings).paymentGateway") as? String else { return nil }
            guard let paymentProvider = PaymentGateway(rawValue: paymentGatewayString) else { return nil } // Will always be initialized since it's was successfully encoded
            return paymentProvider
            }() else { return nil}

        self.paymentGateway = paymentGateway

        self.chatCreditFeature = false
        if let value = aDecoder.decodeObjectForKey("\(literal.Settings).chatCreditFeature") as? Bool {
            self.chatCreditFeature = value
        }

        self.chatCreditPercentage = 0
        if let creditPercentage = aDecoder.decodeObjectForKey("\(literal.Settings).chatCreditPercentage") as? Int {
            self.chatCreditPercentage = creditPercentage
        }

        guard let appCompany = { () -> AppCompany? in
            guard let appCompanyString = aDecoder.decodeObjectForKey("\(literal.Settings).appCompany") as? String else { return nil}

            guard let appCompany = AppCompany(rawValue: appCompanyString) else { return nil}
            return appCompany
            }() else { return nil }
        self.appCompany = appCompany

        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(paymentGateway.rawValue,
                            forKey: "\(literal.Settings).paymentGateway")
        aCoder.encodeObject(chatCreditFeature,
                            forKey: "\(literal.Settings).chatCreditFeature")
        aCoder.encodeObject(chatCreditPercentage,
                            forKey: "\(literal.Settings).chatCreditPercentage")
        aCoder.encodeObject(appCompany.rawValue,
                            forKey: "\(literal.Settings).appCompany")

    }

}

extension Settings: Defaultable {
    @nonobjc static let defaultValue = Settings(paymentGateway: PaymentGateway.defaultValue, chatCreditFeature: false, chatCreditPercentage: 0, appCompany: AppCompany.defaultValue)
}

extension Settings: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> Settings? {

        guard let json = jsonRepresentation?["feature_flags"] as? [String : AnyObject] else {
            return nil
        }

        guard let paymentGateway: PaymentGateway = { () -> PaymentGateway? in
            guard let value = json["payment_gateway"] as? String else { return nil }
                let restul = PaymentGateway(rawValue: value)
                return restul
            }() else { return nil }

        var chatCreditFeature = false
        if let feature = json["chat_credit_enabled"] as? Bool {
            chatCreditFeature = feature
        }

        var chatCreditPercentage = 0
        if let chatPercentage = json["chat_credit_percentage"] as? Int {
            chatCreditPercentage = chatPercentage
        }

        let appCompany: AppCompany = { () -> AppCompany in
            guard let value = json["app_company"] as? String else { return AppCompany.defaultValue }
            guard let restul = AppCompany(rawValue: value) else { return AppCompany.defaultValue }
            return restul
            }()

        let result = Settings(
            paymentGateway: paymentGateway,
            chatCreditFeature: chatCreditFeature,
            chatCreditPercentage: chatCreditPercentage,
            appCompany: appCompany
        )
        return result
    }
}
