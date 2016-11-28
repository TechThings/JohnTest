//
//  ListingOpenVoucherDetails.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol ListingOpenVoucherDetailsType: ListingDetailsType, ListingOpenVoucherType {}

final class ListingOpenVoucherDetails: ListingOpenVoucher, ListingOpenVoucherDetailsType {
    let paymentGateways: [PaymentGateway]
    let primaryPaymentGateway: PaymentGateway
    let redemptionInstructions: String?
    let redemptionMethod: RedemptionMethod

    init(listingOpenVoucher: ListingOpenVoucher
        , paymentGateways: [PaymentGateway]
        , primaryPaymentGateway: PaymentGateway
        , redemptionInstructions: String?
        , redemptionMethod: RedemptionMethod
        ) {
        self.paymentGateways = paymentGateways
        self.primaryPaymentGateway = primaryPaymentGateway
        self.redemptionInstructions = redemptionInstructions
        self.redemptionMethod = redemptionMethod

        let listing = Listing(id: listingOpenVoucher.id, name: listingOpenVoucher.name, listingDescription: listingOpenVoucher.listingDescription, category: listingOpenVoucher.category, tips: listingOpenVoucher.tips, tags: listingOpenVoucher.tags, featuredImage: listingOpenVoucher.featuredImage, featuredThumbnailImage: listingOpenVoucher.featuredThumbnailImage, company: listingOpenVoucher.company, outlet: listingOpenVoucher.outlet, purchaseDetails: listingOpenVoucher.purchaseDetails, pricingBySlots: listingOpenVoucher.pricingBySlots, option: listingOpenVoucher.option, finePrint: listingOpenVoucher.finePrint, whatYouGet: listingOpenVoucher.whatYouGet, galleryImages: listingOpenVoucher.galleryImages, categoryType: listingOpenVoucher.categoryType, shareMessage: listingOpenVoucher.shareMessage, featuredLabel: listingOpenVoucher.featuredLabel,cancellationPolicy: listingOpenVoucher.cancellationPolicy, collections: listingOpenVoucher.collections, showCancellation: listingOpenVoucher.showCancellationPolicy, showFavePromise: listingOpenVoucher.showFavePromise, totalRedeemableOutlets: listingOpenVoucher.totalRedeemableOutlets)
        super.init(listing: listing, voucherDetail: listingOpenVoucher.voucherDetail)
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

extension ListingOpenVoucherDetails {
    override final class func serialize(jsonRepresentation: AnyObject?) -> ListingOpenVoucherDetails? {
        guard let json = jsonRepresentation as? [String : AnyObject] else { return nil }

        // Properties to initialize (copy from the object being serilized)

        guard let listingOpenVoucher = ListingOpenVoucher.serialize(json) else { return nil}

        var paymentGateways = [PaymentGateway]()
        guard let paymentGatewaysString = json["payment_gateways"] as? [String] else { return nil}
        for paymentGatewayString in paymentGatewaysString {
            print(paymentGatewayString)
            if let paymentGateway = PaymentGateway(rawValue: paymentGatewayString) {
                paymentGateways.append(paymentGateway)
            }
        }

        let redemptionInstructions = json["redemption_instructions"] as? String

        guard let redemptionValue = json["redemption_method"] as? String else { return nil }
        guard let redemptionMethod = RedemptionMethod(rawValue: redemptionValue) else { return nil }

        guard let primaryPaymentGateway = paymentGateways.first else { return nil }

        let result = ListingOpenVoucherDetails(listingOpenVoucher: listingOpenVoucher, paymentGateways: paymentGateways, primaryPaymentGateway: primaryPaymentGateway, redemptionInstructions: redemptionInstructions, redemptionMethod: redemptionMethod)
        return result
    }
}
