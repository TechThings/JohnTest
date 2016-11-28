//
//  UserCredits.swift
//  fave
//
//  Created by Michael Cheah on 7/16/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation

final class UserCredits: NSObject {

    let currency: String
    let credits: String
    let referralCode: String
    let referralDescription: String
    let shareMessages: ShareMessage
    let creditCents: Int

    init(currency: String,
         credits: String,
         referralCode: String,
         referralDescription: String,
         shareMessages: ShareMessage,
         creditCents: Int) {
        self.currency = currency
        self.credits = credits
        self.referralCode = referralCode
        self.referralDescription = referralDescription
        self.shareMessages = shareMessages
        self.creditCents = creditCents
    }
}

extension UserCredits: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> UserCredits? {

        let shareMessages: ShareMessage

        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        guard let currency = json["currency"] as? String else {
            return nil
        }

        guard let credits = json["credits"] as? String else {
            return nil
        }

        guard let referralCode = json["referral_code"] as? String else {
            return nil
        }

        guard let referralDescription = json["referral_description"] as? String else {
            return nil
        }

        if let sharingJson = json["sharing"] {
            guard let sharingMessage = ShareMessage.serialize(sharingJson) else {
                return nil
            }
            shareMessages = sharingMessage
        } else {
            return nil
        }

        guard let creditsCents = json["credits_cents"] as? Int else {
            return nil
        }

        let result = UserCredits(currency: currency, credits: credits, referralCode: referralCode, referralDescription: referralDescription, shareMessages: shareMessages, creditCents: creditsCents)
        return result
    }
}
