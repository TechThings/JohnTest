//
//  PaymentReceipt.swift
//  fave
//
//  Created by Michael Cheah on 7/12/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class PaymentReceipt: NSObject {

    let title: String
    let created_at: NSDate
    let reference_number: String
    let amount: String
    let url: NSURL?
    let offerName: String

    init(title: String
         , created_at: NSDate
         , reference_number: String
         , amount: String
         , url: NSURL?
        , offerName: String
        ) {
        self.title = title
        self.created_at = created_at
        self.reference_number = reference_number
        self.amount = amount
        self.url = url
        self.offerName = offerName
    }
}

extension PaymentReceipt: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> PaymentReceipt? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        guard let title = json["title"] as? String else {
            return nil
        }

        guard let created_at_string = json["created_at"] as? String,
                let created_at = created_at_string.RFC3339DateTime else {
            return nil
        }

        guard let reference_number = json["reference_number"] as? String else {
            return nil
        }

        guard let amount = json["amount"] as? String else {
            return nil
        }

        guard let offerName = json["offer_name"] as? String else {
            return nil
        }

        let url = { () -> NSURL? in
            if let value = json["url"] as? String {
                return NSURL(string: value)
            }

            return nil
        }()

        let result = PaymentReceipt(title: title
            , created_at: created_at
            , reference_number: reference_number
            , amount: amount
            , url: url
            , offerName: offerName
        )
        return result
    }
}
