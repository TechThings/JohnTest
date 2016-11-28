//
//  Listings.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 Kfit. All rights reserved.
//

import UIKit

class Listing: NSObject, NSCoding, ListingType {
    let id: Int
    let name: String
    let listingDescription: String?
    let category: SubCategory
    let tips: String?
    let tags: [String]
    let featuredImage: NSURL?
    let featuredThumbnailImage: NSURL?
    let company: Company
    let outlet: Outlet
    let purchaseDetails: PurchaseDetails
    let pricingBySlots: [PurchaseDetails]?
    let option: ListingOption
    let finePrint: String?
    let whatYouGet: String?
    let galleryImages: [NSURL]
    let categoryType: String
    let shareMessage: ShareMessage?
    let featuredLabel: String?

    let showCancellationPolicy: Bool?
    let showFavePromise: Bool?
    let cancellationPolicy: String?
    let collections: [ListingsCollection]?

    let totalRedeemableOutlets: Int?

    init(id: Int
        , name: String
        , listingDescription: String?
        , category: SubCategory
        , tips: String?
        , tags: [String]
        , featuredImage: NSURL?
        , featuredThumbnailImage: NSURL?
        , company: Company
        , outlet: Outlet
        , purchaseDetails: PurchaseDetails
        , pricingBySlots: [PurchaseDetails]?
        , option: ListingOption
        , finePrint: String?
        , whatYouGet: String?
        , galleryImages: [NSURL]
        , categoryType: String
        , shareMessage: ShareMessage?
        , featuredLabel: String?
        , cancellationPolicy: String?
        , collections: [ListingsCollection]?
        , showCancellation: Bool?
        , showFavePromise: Bool?
        , totalRedeemableOutlets: Int?
        ) {
        self.galleryImages = galleryImages
        self.id = id
        self.name = name
        self.listingDescription = listingDescription
        self.category = category
        self.tips = tips
        self.tags = tags
        self.featuredImage = featuredImage
        self.featuredThumbnailImage = featuredThumbnailImage
        self.company = company
        self.outlet = outlet
        self.purchaseDetails = purchaseDetails
        self.pricingBySlots = pricingBySlots
        self.option = option
        self.finePrint = finePrint
        self.whatYouGet = whatYouGet
        self.categoryType = categoryType
        self.shareMessage = shareMessage
        self.featuredLabel = featuredLabel

        self.showCancellationPolicy = showCancellation
        self.showFavePromise = showFavePromise
        self.cancellationPolicy = cancellationPolicy
        self.collections = collections
        self.totalRedeemableOutlets = totalRedeemableOutlets
        super.init()
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObjectForKey("\(literal.Listing).id") as? Int else { return nil }
        self.id = id
        guard let name = aDecoder.decodeObjectForKey("\(literal.Listing).name") as? String else { return nil }
        self.name = name
        self.listingDescription = aDecoder.decodeObjectForKey("\(literal.Listing).listingDescription") as? String
        self.purchaseDetails = aDecoder.decodeObjectForKey("\(literal.Listing).purchaseDetails") as! PurchaseDetails
        self.pricingBySlots = aDecoder.decodeObjectForKey("\(literal.Listing).pricingBySlots") as? [PurchaseDetails]
        self.featuredImage = aDecoder.decodeObjectForKey("\(literal.Listing).featuredImage") as? NSURL
        self.featuredThumbnailImage = aDecoder.decodeObjectForKey("\(literal.Listing).featuredThumbnailImage") as? NSURL
        guard let company = aDecoder.decodeObjectForKey("\(literal.Listing).company") as? Company else { return nil }
        self.company = company
        guard let outlet = aDecoder.decodeObjectForKey("\(literal.Listing).outlet") as? Outlet else { return nil }
        self.outlet = outlet
        self.tips = aDecoder.decodeObjectForKey("\(literal.Listing).tips") as? String
        guard let category = aDecoder.decodeObjectForKey("\(literal.Listing).category") as? SubCategory else { return nil }
        self.category = category
        guard let tags = aDecoder.decodeObjectForKey("\(literal.Listing).tags") as? [String] else { return nil }
        self.tags = tags

        self.option = {
            // The name of the variable has changed. Hecne the name of the key has changed. Inorder to satesfy the requirments of the order versions of the app, we decaode with the old key first
            var optionString = ListingOption.OpenVoucher.rawValue
            if let optinalTypeString = aDecoder.decodeObjectForKey("\(literal.Listing).type") as? String {
                optionString = optinalTypeString
            }
            if let optionalOptionString = aDecoder.decodeObjectForKey("\(literal.Listing).option") as? String {
                optionString = optionalOptionString
            }
            return ListingOption(rawValue: optionString)!
        }()

        self.finePrint = aDecoder.decodeObjectForKey("\(literal.Listing).finePrint") as? String
        self.whatYouGet = aDecoder.decodeObjectForKey("\(literal.Listing).whatYouGet") as? String
        guard let galleryImages = aDecoder.decodeObjectForKey("\(literal.Listing).galleryImages") as? [NSURL] else { return nil }
        guard let categoryType = aDecoder.decodeObjectForKey("\(literal.Listing).categoryType") as? String else { return nil }
        self.categoryType = categoryType
        self.galleryImages = galleryImages
        self.shareMessage = aDecoder.decodeObjectForKey("\(literal.Listing).shareMessage") as? ShareMessage
        self.featuredLabel = aDecoder.decodeObjectForKey("\(literal.Listing).featuredLabel") as? String

        self.showCancellationPolicy = aDecoder.decodeObjectForKey("\(literal.Listing).showCancellationPolicy") as? Bool
        self.showFavePromise = aDecoder.decodeObjectForKey("\(literal.Listing).showFavePromise") as? Bool
        self.cancellationPolicy = aDecoder.decodeObjectForKey("\(literal.Listing).cancellationPolicy") as? String
        self.collections = aDecoder.decodeObjectForKey("\(literal.Listing).collections") as? [ListingsCollection]

        self.totalRedeemableOutlets = aDecoder.decodeObjectForKey("\(literal.Listing).totalRedeemableOutlets") as? Int

        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: "\(literal.Listing).id")
        aCoder.encodeObject(name, forKey: "\(literal.Listing).name")
        aCoder.encodeObject(listingDescription, forKey: "\(literal.Listing).listingDescription")
        aCoder.encodeObject(purchaseDetails, forKey: "\(literal.Listing).purchaseDetails")
        aCoder.encodeObject(pricingBySlots, forKey: "\(literal.Listing).pricingBySlots")
        aCoder.encodeObject(featuredImage, forKey: "\(literal.Listing).featuredImage")
        aCoder.encodeObject(featuredThumbnailImage, forKey: "\(literal.Listing).featuredThumbnailImage")
        aCoder.encodeObject(company, forKey: "\(literal.Listing).company")
        aCoder.encodeObject(outlet, forKey: "\(literal.Listing).outlet")
        aCoder.encodeObject(tips, forKey: "\(literal.Listing).tips")
        aCoder.encodeObject(category, forKey: "\(literal.Listing).category")
        aCoder.encodeObject(tags, forKey: "\(literal.Listing).tags")
        aCoder.encodeObject(option.rawValue, forKey: "\(literal.Listing).option")
        aCoder.encodeObject(finePrint, forKey: "\(literal.Listing).finePrint")
        aCoder.encodeObject(whatYouGet, forKey: "\(literal.Listing).whatYouGet")
        aCoder.encodeObject(galleryImages, forKey: "\(literal.Listing).galleryImages")
        aCoder.encodeObject(categoryType, forKey: "\(literal.Listing).categoryType")
        aCoder.encodeObject(shareMessage, forKey: "\(literal.Listing).shareMessage")
        aCoder.encodeObject(featuredLabel, forKey: "\(literal.Listing).featuredLabel")
        aCoder.encodeObject(cancellationPolicy, forKey: "\(literal.Listing).cancellationPolicy")
        aCoder.encodeObject(collections, forKey: "\(literal.Listing).collections")
        aCoder.encodeObject(showCancellationPolicy, forKey: "\(literal.Listing).showCancellationPolicy")
        aCoder.encodeObject(showCancellationPolicy, forKey: "\(literal.Listing).showFavePromise")
        aCoder.encodeObject(totalRedeemableOutlets, forKey: "\(literal.Listing).totalRedeemableOutlets")
    }
}

extension Listing: Serializable {
    class func serialize(jsonRepresentation: AnyObject?) -> Listing? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let id = {
            return json["id"] as? Int
            }() else {
                return nil
        }

        guard let name = json["name"] as? String else { return nil }
        let listingDescription = json["description"] as? String

        guard let category = SubCategory.serialize(json["category"]) else { return nil }

        let tips = json["tips"] as? String

        let tags = { () -> [String] in
            if let value = json["tags"] as? [String] {
                return value
            } else {
                return [String]()
            }
        }()

        let featuredImage = { () -> NSURL? in
            guard let value = json["featured_image"] as? String else {return nil}
            return NSURL(string: value)
        }()

        let featuredThumbnailImage = { () -> NSURL? in
            guard let value = json["featured_thumbnail_image"] as? String else {return nil}
            return NSURL(string: value)
        }()

        guard let company = Company.serialize( json["company"]) else { return nil }

        guard let outlet = Outlet.serialize(json["outlet"])  else { return nil }

        guard let purchaseDetails = PurchaseDetails.serialize(json["purchase_details"]) else { return nil }

        var pricingBySlots: [PurchaseDetails]?
        if let values = json["pricing_by_slots"] as? [AnyObject] {
            pricingBySlots = [PurchaseDetails]()
            for pricingRepresentation in values {
                if let detail = PurchaseDetails.serialize(pricingRepresentation) {
                    pricingBySlots?.append(detail)
                }
            }
        }

        guard let option = {() -> ListingOption? in
            let value = json["listing_type"] as! String
            if value == ListingOption.OpenVoucher.rawValue {
                return ListingOption.OpenVoucher
            } else {
                return ListingOption.TimeSlot
            }
            }() else { return nil }

        let finePrint = json["fine_print"] as? String

        let whatYouGet = json["what_you_get"] as? String

        let galleryImages = { () -> [NSURL] in
            var gallery = [NSURL]()
            if let value = json["gallery_images"] as? [String] {
                for image in value {
                    gallery.append(NSURL(string: image)!)
                }
            }
            return gallery
        }()

        guard let categoryType = json["category_type"] as? String else { return nil }

        var shareMessage: ShareMessage? = nil
        if let value = json["share"] {
            shareMessage = ShareMessage.serialize(value)
        }

        let featuredLabel = json["featured_label"] as? String
        let cancellation = json["cancellation_policy"] as? String
        let showCancellation = json["show_cancellation_policy"] as? Bool
        let showFavePromise = json["show_fave_promise"] as? Bool

        var collections: [ListingsCollection]?

        if let values = json["collections"] as? [AnyObject] {
            collections = [ListingsCollection]()

            for collection in values {
                if let a_collection = ListingsCollection.serialize(collection) {
                    collections?.append(a_collection)
                }
            }
        }

        var totalRedeemableOutlets: Int?
        // Backend naming problem... Why set the key as `total` but the value is `total - 1` >_<
        if let remainRedeemableOutlets = json["total_redeemable_outlets"] as? Int {
            totalRedeemableOutlets = remainRedeemableOutlets + 1
        }

        let result = Listing(id: id, name: name, listingDescription: listingDescription, category: category, tips: tips, tags: tags, featuredImage: featuredImage, featuredThumbnailImage: featuredThumbnailImage, company: company, outlet: outlet, purchaseDetails: purchaseDetails, pricingBySlots: pricingBySlots, option: option, finePrint: finePrint, whatYouGet: whatYouGet, galleryImages: galleryImages, categoryType: categoryType, shareMessage: shareMessage, featuredLabel: featuredLabel, cancellationPolicy: cancellation, collections: collections, showCancellation: showCancellation, showFavePromise: showFavePromise, totalRedeemableOutlets: totalRedeemableOutlets)

        return result
    }
}
