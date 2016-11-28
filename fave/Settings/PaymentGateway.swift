//
//  PaymentGateway.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
enum PaymentGateway: String {
    case Braintree = "braintree"
    case Adyen = "adyen"
    case Veritrans = "veritrans"
}

extension PaymentGateway: Defaultable {
    static let defaultValue = PaymentGateway.Adyen
}
