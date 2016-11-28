//
//  PurchaseDetails.swift
//  KFIT
//
//  Created by Nazih Shoura on 16/03/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

final class PurchaseDetails: NSObject, NSCoding {
    let originalPriceUserVisible: String
    let savingsUserVisible: String?
    let promoSavingsUserVisible: String?
    let finalPriceUserVisible: String
    let discountPriceUserVisible: String
    let slots: Int

    let promoCode: String?
    let totalChargeAmountUserVisible: String?
    let totalChargeAmount: Double
    let isFree: Bool?

    let creditUsed: String?

    init(originalPriceUserVisible: String
        , savingsUserVisible: String?
        , promoSavingsUserVisible: String?
        , finalPriceUserVisible: String
        , discountPriceUserVisible: String
        , slots: Int
        , promoCode: String?
        , totalChargeAmountUserVisible: String?
        , isFree: Bool?
        , creditUsed: String?
        , totalChargeAmount: Double
        ) {
        self.totalChargeAmount = totalChargeAmount
        self.originalPriceUserVisible = originalPriceUserVisible
        self.savingsUserVisible = savingsUserVisible
        self.promoSavingsUserVisible = promoSavingsUserVisible
        self.finalPriceUserVisible = finalPriceUserVisible
        self.discountPriceUserVisible = discountPriceUserVisible
        self.slots = slots

        self.promoCode          = promoCode
        self.totalChargeAmountUserVisible  = totalChargeAmountUserVisible
        self.isFree = isFree
        self.creditUsed = creditUsed
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.originalPriceUserVisible = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).originalPriceUserVisible") as! String
        self.savingsUserVisible = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).savingsUserVisible") as? String
        self.promoSavingsUserVisible = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).promoSavingsUserVisible") as? String
        self.finalPriceUserVisible = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).finalPriceUserVisible") as! String
        self.discountPriceUserVisible = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).discountPriceUserVisible") as! String
        self.slots = aDecoder.decodeIntegerForKey("\(PurchaseDetails.subjectLabel).slots")
        self.totalChargeAmount = aDecoder.decodeDoubleForKey("\(PurchaseDetails.subjectLabel).totalChargeAmount")

        self.promoCode          = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).promo_code") as? String
        self.totalChargeAmountUserVisible  = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).totalChargeAmountUserVisible") as? String
        self.creditUsed  = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).creditUsed") as? String
        self.isFree  = aDecoder.decodeObjectForKey("\(PurchaseDetails.subjectLabel).isFree") as? Bool
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(originalPriceUserVisible, forKey: "\(self.subjectLabel).originalPriceUserVisible")
        aCoder.encodeObject(savingsUserVisible, forKey: "\(self.subjectLabel).savingsUserVisible")
        aCoder.encodeObject(promoSavingsUserVisible, forKey: "\(self.subjectLabel).promoSavingsUserVisible")
        aCoder.encodeObject(finalPriceUserVisible, forKey: "\(self.subjectLabel).finalPriceUserVisible")
        aCoder.encodeObject(discountPriceUserVisible, forKey: "\(self.subjectLabel).discountPriceUserVisible")
        aCoder.encodeInteger(slots, forKey: "\(self.subjectLabel).slots")
        aCoder.encodeDouble(totalChargeAmount, forKey: "\(self.subjectLabel).totalChargeAmount")

        aCoder.encodeObject(promoCode, forKey: "\(self.subjectLabel).promoCode")
        aCoder.encodeObject(totalChargeAmountUserVisible, forKey: "\(self.subjectLabel).totalChargeAmountUserVisible")
        aCoder.encodeObject(creditUsed, forKey: "\(self.subjectLabel).creditUsed")
        aCoder.encodeObject(isFree, forKey: "\(self.subjectLabel).creditUsed")
    }
}

extension PurchaseDetails: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> PurchaseDetails? {

        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        // Properties to initialize (copy from the object being serilized)
        var originalPriceUserVisible: String?
        var savingsUserVisible: String?
        var promoSavingsUserVisible: String?
        var finalPriceUserVisible: String?
        var discountPriceUserVisible: String?
        var slots: Int?
        var promoCode: String?
        var creditUsed: String?
        var isFree: Bool?

        // Properties initialization
        if let value = json["original_price"] as? String {
            originalPriceUserVisible = value
        }

        if let value = json["savings"] as? String {
            savingsUserVisible = value
        }

        if let value = json["promo_savings"] as? String {
            promoSavingsUserVisible = value
        }

        if let value = json["final_price"] as? String {
            finalPriceUserVisible = value
        }

        if let value = json["discounted_price"] as? String {
            discountPriceUserVisible = value
        }

        if let value = json["slots"] as? Int {
            slots = value
        }

        if let value = json["promo_code"] as? String {
            promoCode = value
        }
        guard let totalChargeAmount = { () -> Double? in
            guard let value = json["total_chargeable_amount_value"] as? String else { return nil}
            return Double(value)

            }() else { return nil }

        let totalChargeAmountUserVisible = json["total_chargeable_amount"] as? String

        creditUsed = json["credit_used"] as? String
        isFree = json["is_free"] as? Bool

        // Verify properties and initialize object
        if let originalPriceUserVisible = originalPriceUserVisible
            , let finalPriceUserVisible = finalPriceUserVisible
            , let discountPriceUserVisible = discountPriceUserVisible
            , let slots = slots {
            let result = PurchaseDetails(originalPriceUserVisible: originalPriceUserVisible
                , savingsUserVisible: savingsUserVisible
                , promoSavingsUserVisible: promoSavingsUserVisible
                , finalPriceUserVisible: finalPriceUserVisible
                , discountPriceUserVisible: discountPriceUserVisible
                , slots: slots
                , promoCode: promoCode
                , totalChargeAmountUserVisible: totalChargeAmountUserVisible
                , isFree: isFree
                , creditUsed: creditUsed
                , totalChargeAmount: totalChargeAmount
            )
            return result
        }
        return nil
    }
}
