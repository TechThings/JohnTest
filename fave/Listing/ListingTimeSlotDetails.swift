//
//  ListingTimeSlotDetails.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol ListingTimeSlotDetailsType: ListingDetailsType, ListingTimeSlotType {}

final class ListingTimeSlotDetails: ListingTimeSlot, ListingTimeSlotDetailsType {
    let paymentGateways: [PaymentGateway]
    let primaryPaymentGateway: PaymentGateway
    let redemptionInstructions: String?
    let redemptionMethod: RedemptionMethod

    init(listingTimeSlot: ListingTimeSlot
        , paymentGateways: [PaymentGateway]
        , primaryPaymentGateway: PaymentGateway
        , redemptionInstructions: String?
        , redemptionMethod: RedemptionMethod
        ) {
        self.paymentGateways = paymentGateways
        self.primaryPaymentGateway = primaryPaymentGateway
        self.redemptionInstructions = redemptionInstructions
        self.redemptionMethod = redemptionMethod

        let listing = Listing(id: listingTimeSlot.id, name: listingTimeSlot.name, listingDescription: listingTimeSlot.listingDescription, category: listingTimeSlot.category, tips: listingTimeSlot.tips, tags: listingTimeSlot.tags, featuredImage: listingTimeSlot.featuredImage, featuredThumbnailImage: listingTimeSlot.featuredThumbnailImage, company: listingTimeSlot.company, outlet: listingTimeSlot.outlet, purchaseDetails: listingTimeSlot.purchaseDetails, pricingBySlots: listingTimeSlot.pricingBySlots, option: listingTimeSlot.option, finePrint: listingTimeSlot.finePrint, whatYouGet: listingTimeSlot.whatYouGet, galleryImages: listingTimeSlot.galleryImages, categoryType: listingTimeSlot.categoryType, shareMessage: listingTimeSlot.shareMessage, featuredLabel: listingTimeSlot.featuredLabel, cancellationPolicy: listingTimeSlot.cancellationPolicy, collections: listingTimeSlot.collections, showCancellation:listingTimeSlot.showCancellationPolicy, showFavePromise: listingTimeSlot.showFavePromise, totalRedeemableOutlets: listingTimeSlot.totalRedeemableOutlets)
        super.init(listing: listing, nextClassSession: listingTimeSlot.nextClassSession, classSessions: listingTimeSlot.classSessions)
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        let paymentGatewaysString = aDecoder.decodeObjectForKey("\(literal.Listing).paymentGateways") as! [String]
        self.paymentGateways = paymentGatewaysString.map({ (string) -> PaymentGateway in
            return PaymentGateway(rawValue: string)!
        })

        let primaryPaymentGatewayString = aDecoder.decodeObjectForKey("\(literal.Listing).primaryPaymentGateway") as! String
        self.primaryPaymentGateway = PaymentGateway(rawValue: primaryPaymentGatewayString)!

        self.redemptionInstructions = aDecoder.decodeObjectForKey("\(literal.Listing).redemptionInstructions") as? String

        if let redemption = aDecoder.decodeObjectForKey("\(literal.Listing).redemptionMethod") as? String,  let redeem = RedemptionMethod(rawValue: redemption) {
            self.redemptionMethod = redeem
        } else {
            self.redemptionMethod = RedemptionMethod.defaultValue
        }

        super.init(coder: aDecoder)
    }

    @objc override func encodeWithCoder(aCoder: NSCoder) {
        let paymentGatewaysString = paymentGateways.map { (paymentGateway) -> String in
            return paymentGateway.rawValue
        }
        aCoder.encodeObject(paymentGatewaysString, forKey: "\(literal.Listing).paymentGateways")

        let primaryPaymentGatewayString = primaryPaymentGateway.rawValue
        aCoder.encodeObject(primaryPaymentGatewayString, forKey: "\(literal.Listing).primaryPaymentGatewayString")

        aCoder.encodeObject(redemptionInstructions, forKey: "\(literal.Listing).redemptionInstructions")
        aCoder.encodeObject(redemptionMethod.rawValue, forKey: "\(literal.Listing).redemptionMethod")

        super.encodeWithCoder(aCoder)
    }
}

extension ListingTimeSlotDetails {
    override class func serialize(jsonRepresentation: AnyObject?) -> ListingTimeSlotDetails? {

        guard let json = jsonRepresentation as? [String : AnyObject] else { return nil }

        // Properties to initialize (copy from the object being serilized)

        guard let listingTimeSlot = ListingTimeSlot.serialize(json) else { return nil}

        var paymentGateways = [PaymentGateway]()
        guard let paymentGatewaysString = json["payment_gateways"] as? [String] else { return nil}
        for paymentGatewayString in paymentGatewaysString {
            if let paymentGateway = PaymentGateway(rawValue: paymentGatewayString) {
                paymentGateways.append(paymentGateway)
            }
        }

        let redemptionInstructions = json["redemption_instructions"] as? String

        guard let redemptionValue = json["redemption_method"] as? String else { return nil }
        guard let redemptionMethod = RedemptionMethod(rawValue: redemptionValue) else { return nil }

        guard let primaryPaymentGateway = paymentGateways.first else { return nil }
        let result = ListingTimeSlotDetails(listingTimeSlot: listingTimeSlot, paymentGateways: paymentGateways, primaryPaymentGateway: primaryPaymentGateway, redemptionInstructions: redemptionInstructions, redemptionMethod: redemptionMethod)

        return result
    }
}
