//
//  PaymentMethodNonceResult.swift
//  fave
//
//  Created by Michael Cheah on 7/8/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Braintree

final class BTPaymentMethodNonceResult: NSObject {

    let btPaymentMethodNonce: BTPaymentMethodNonce?

    init(btPaymentMethodNonce: BTPaymentMethodNonce?) {
        self.btPaymentMethodNonce = btPaymentMethodNonce
    }
}
