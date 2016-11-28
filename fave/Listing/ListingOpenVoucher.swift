//
//  ListingOpenVoucher.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol ListingOpenVoucherType: ListingType {
    var voucherDetail: VoucherDetail? { get }
}

class ListingOpenVoucher: Listing, ListingOpenVoucherType {
    let voucherDetail: VoucherDetail?

    init(listing: ListingType,
         voucherDetail: VoucherDetail?
        ) {
        self.voucherDetail = voucherDetail

        super.init(id: listing.id, name: listing.name, listingDescription: listing.listingDescription, category: listing.category, tips: listing.tips, tags: listing.tags, featuredImage: listing.featuredImage, featuredThumbnailImage: listing.featuredThumbnailImage, company: listing.company, outlet: listing.outlet, purchaseDetails: listing.purchaseDetails, pricingBySlots: listing.pricingBySlots, option: listing.option, finePrint: listing.finePrint, whatYouGet: listing.whatYouGet, galleryImages: listing.galleryImages, categoryType: listing.categoryType, shareMessage: listing.shareMessage, featuredLabel: listing.featuredLabel, cancellationPolicy: listing.cancellationPolicy, collections: listing.collections, showCancellation: listing.showCancellationPolicy, showFavePromise: listing.showFavePromise, totalRedeemableOutlets: listing.totalRedeemableOutlets)
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.voucherDetail = aDecoder.decodeObjectForKey("\(ListingOpenVoucher.subjectLabel).voucherDetail") as? VoucherDetail
        super.init(coder: aDecoder)
    }

    @objc override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(voucherDetail, forKey: "\(self.subjectLabel).voucherDetail")
        super.encodeWithCoder(aCoder)
    }
}

extension ListingOpenVoucher {
    override class func serialize(jsonRepresentation: AnyObject?) -> ListingOpenVoucher? {

        guard let json = jsonRepresentation as? [String : AnyObject] else { return nil }

        guard let listing = Listing.serialize(json) else { return nil}

        let detailsValue = json["voucher_detail"] as? [String : AnyObject], voucherDetails = VoucherDetail.serialize(detailsValue)

        let result = ListingOpenVoucher(listing: listing, voucherDetail: voucherDetails)

        return result
    }
}
