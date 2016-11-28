//
//  Promo.swift
//  KFIT
//
//  Created by Nazih Shoura on 08/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

final class Promo: NSObject {
    let id: Int
    let code: String
    let discountUserVisible: String
    let expiryDatetime: NSDate?
    let marketingDescriptionUserVisible: String?
    let discountDescriptionUserVisible: String?
    let isForFirstPurchaseOnly: Bool
    init(
        id: Int,
        code: String,
        discountUserVisible: String,
        expiryDatetime: NSDate?,
        marketingDescriptionUserVisible: String?,
        discountDescriptionUserVisible: String?,
        isForFirstPurchaseOnly: Bool
        ) {
        self.id = id
        self.code = code
        self.discountUserVisible = discountUserVisible
        self.expiryDatetime = expiryDatetime
        self.marketingDescriptionUserVisible = marketingDescriptionUserVisible
        self.discountDescriptionUserVisible = discountDescriptionUserVisible
        self.isForFirstPurchaseOnly = isForFirstPurchaseOnly
    }
}

extension Promo: Serializable {
    typealias Type = Promo

    static func serialize(jsonRepresentation: AnyObject?) -> Promo? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize (copy from the object being serilized)
        var id: Int!
        var code: String!
        var discountUserVisible: String!
        var expiryDatetime: NSDate?
        var marketingDescriptionUserVisible: String?
        var discountDescriptionUserVisible: String?
        var isForFirstPurchaseOnly: Bool!

        // Properties initialization
        if let value = json["id"] as? Int {
            id = value
        }
        if let value = json["code"] as? String {
            code = value
        }
        if let value = json["discount"] as? String {
            discountUserVisible = value
        }
        if let value = json["expiration_date"] as? String {
            expiryDatetime = value.PromoDateTime
        }
        if let value = json["marketing_description"] as? String {
            marketingDescriptionUserVisible = value
        }
        if let value = json["discount_description"] as? String {
            discountDescriptionUserVisible = value
        }
        if let value = json["first_purchase_only"] as? Bool {
            isForFirstPurchaseOnly = value
        }

        if let _ = discountUserVisible {
            discountUserVisible = ""
        }
        // Verify properties and initialize object
        if let id = id,
            code = code,
            discountUserVisible = discountUserVisible,
            isForFirstPurchaseOnly = isForFirstPurchaseOnly {
            let result = Promo(id: id, code: code, discountUserVisible: discountUserVisible, expiryDatetime: expiryDatetime, marketingDescriptionUserVisible: marketingDescriptionUserVisible, discountDescriptionUserVisible: discountDescriptionUserVisible,
                isForFirstPurchaseOnly: isForFirstPurchaseOnly)
            return result
        }
        return nil
    }
}
