//
//  ListingGroup.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 Kfit. All rights reserved.
//

import UIKit

class ListingGroup: NSObject, NSCoding, ListingUserVisible {
    let id: Int
    let name: String
    let type: ListingOption
    let listingDescription: String?
    let category: SubCategory
    let tips: String?
    let tags: [String]
    let featuredImage: NSURL?
    let featuredThumbnailImage: NSURL?
    let purchaseDetails: PurchaseDetails
    let pricingBySlots: [PurchaseDetails]?
    let finePrint: String?
    let galleryImages: [NSURL]
    let categoryType: String
    let shareMessage: ShareMessage?
    let featuredLabel: String?

    let cancellationPolicy: String?
    let collections: [ListingsCollection]?

    init(id: Int
        , name: String
        , listingDescription: String?
        , category: SubCategory
        , tips: String?
        , tags: [String]
        , featuredImage: NSURL?
        , featuredThumbnailImage: NSURL?
        , purchaseDetails: PurchaseDetails
        , pricingBySlots: [PurchaseDetails]?
        , type: ListingOption
        , finePrint: String?
        , galleryImages: [NSURL]
        , categoryType: String
        , shareMessage: ShareMessage?
        , featuredLabel: String?
        , cancellationPolicy: String?
        , collections: [ListingsCollection]?
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
        self.purchaseDetails = purchaseDetails
        self.pricingBySlots = pricingBySlots
        self.type = type
        self.finePrint = finePrint
        self.categoryType = categoryType
        self.shareMessage = shareMessage
        self.featuredLabel = featuredLabel
        self.cancellationPolicy = cancellationPolicy
        self.collections = collections
        super.init()
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("\(literal.ListingGroup).id")
        guard let name = aDecoder.decodeObjectForKey("\(literal.ListingGroup).name") as? String else {
            return nil
        }
        self.name = name

        self.listingDescription = aDecoder.decodeObjectForKey("\(literal.ListingGroup).listingDescription") as? String

        guard let purchaseDetails = aDecoder.decodeObjectForKey("\(literal.ListingGroup).purchaseDetails") as? PurchaseDetails else {
            return nil
        }
        self.purchaseDetails = purchaseDetails

        self.pricingBySlots = aDecoder.decodeObjectForKey("\(literal.ListingGroup).pricingBySlots") as? [PurchaseDetails]
        self.featuredImage = aDecoder.decodeObjectForKey("\(literal.ListingGroup).featuredImage") as? NSURL
        self.featuredThumbnailImage = aDecoder.decodeObjectForKey("\(literal.ListingGroup).featuredThumbnailImage") as? NSURL
        self.tips = aDecoder.decodeObjectForKey("\(literal.ListingGroup).tips") as? String

        guard let category = aDecoder.decodeObjectForKey("\(literal.ListingGroup).category") as? SubCategory else {
            return nil
        }
        self.category = category

        guard let tags = aDecoder.decodeObjectForKey("\(literal.ListingGroup).tags") as? [String] else {
            return nil
        }
        self.tags = tags

        guard let typeString = aDecoder.decodeObjectForKey("\(literal.ListingGroup).type") as? String else {
            return nil
        }

        guard let type = ListingOption(rawValue: typeString) else {
            return nil
        }
        self.type = type

        self.finePrint = aDecoder.decodeObjectForKey("\(literal.ListingGroup).finePrint") as? String

        guard let galleryImages = aDecoder.decodeObjectForKey("\(literal.ListingGroup).galleryImages") as? [NSURL] else {
            return nil
        }
        self.galleryImages = galleryImages

        guard let categoryType = aDecoder.decodeObjectForKey("\(literal.ListingGroup).categoryType") as? String else {
            return nil
        }
        self.categoryType = categoryType

        self.shareMessage = aDecoder.decodeObjectForKey("\(literal.ListingGroup).shareMessage") as? ShareMessage
        self.featuredLabel = aDecoder.decodeObjectForKey("\(literal.ListingGroup).featuredLabel") as? String
        self.cancellationPolicy = aDecoder.decodeObjectForKey("\(literal.ListingGroup).cancellationPolicy") as? String
        self.collections = aDecoder.decodeObjectForKey("\(literal.ListingGroup).collections") as? [ListingsCollection]

        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: "\(literal.ListingGroup).id")
        aCoder.encodeObject(name, forKey: "\(literal.ListingGroup).name")
        aCoder.encodeObject(listingDescription, forKey: "\(literal.ListingGroup).listingDescription")
        aCoder.encodeObject(purchaseDetails, forKey: "\(literal.ListingGroup).purchaseDetails")
        aCoder.encodeObject(pricingBySlots, forKey: "\(literal.ListingGroup).pricingBySlots")
        aCoder.encodeObject(featuredImage, forKey: "\(literal.ListingGroup).featuredImage")
        aCoder.encodeObject(featuredThumbnailImage, forKey: "\(literal.ListingGroup).featuredThumbnailImage")
        aCoder.encodeObject(tips, forKey: "\(literal.ListingGroup).tips")
        aCoder.encodeObject(category, forKey: "\(literal.ListingGroup).category")
        aCoder.encodeObject(tags, forKey: "\(literal.ListingGroup).tags")
        aCoder.encodeObject(type.rawValue, forKey: "\(literal.ListingGroup).type")
        aCoder.encodeObject(finePrint, forKey: "\(literal.ListingGroup).finePrint")
        aCoder.encodeObject(galleryImages, forKey: "\(literal.ListingGroup).galleryImages")
        aCoder.encodeObject(categoryType, forKey: "\(literal.ListingGroup).categoryType")
        aCoder.encodeObject(shareMessage, forKey: "\(literal.ListingGroup).shareMessage")
        aCoder.encodeObject(featuredLabel, forKey: "\(literal.ListingGroup).featuredLabel")
        aCoder.encodeObject(cancellationPolicy, forKey: "\(literal.ListingGroup).cancellationPolicy")
        aCoder.encodeObject(collections, forKey: "\(literal.ListingGroup).collections")
    }

}

extension ListingGroup: Serializable {
    class func serialize(jsonRepresentation: AnyObject?) -> ListingGroup? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let id = json["id"] as? Int else {
            return nil
        }

        guard let name = json["name"] as? String else {
            return nil
        }

        let listingDescription = json["description"] as? String

        guard let category = SubCategory.serialize(json["category"]) else {
            return nil
        }

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

        guard let purchaseDetails = PurchaseDetails.serialize(json["purchase_details"]) else { return nil }

        let pricingBySlots: [PurchaseDetails]? = { () -> [PurchaseDetails]? in
            guard let values = json["pricing_by_slots"] as? [AnyObject] else {
                return nil
            }

            var pricingBySlots = [PurchaseDetails]()
            for pricingRepresentation in values {
                if let detail = PurchaseDetails.serialize(pricingRepresentation) {
                    pricingBySlots.append(detail)
                }
            }
            return pricingBySlots
        }()

        guard let type = {() -> ListingOption? in
            guard let typeString = json["listing_type"] as? String else {
                return nil
            }
            guard let type = ListingOption(rawValue: typeString) else {
                return nil
            }
            return type
            }() else {
                return nil
        }

        let finePrint = json["fine_print"] as? String

        let galleryImages = { () -> [NSURL] in
            var gallery = [NSURL]()
            if let value = json["gallery_images"] as? [String] {
                for image in value {
                    if let imageURL = NSURL(string: image) {
                        gallery.append(imageURL)
                    }
                }
            }
            return gallery
        }()

        guard let categoryType = json["category_type"] as? String else { return nil }

        let shareMessage: ShareMessage? = { () -> ShareMessage? in
            guard let value = json["share"] else {
                return nil
            }
            return ShareMessage.serialize(value)
        }()

        let featuredLabel = json["featured_label"] as? String
        let cancellation = json["cancellation_policy"] as? String

        let collections: [ListingsCollection]? = { () -> [ListingsCollection]? in
            guard let values = json["collections"] as? [AnyObject] else {
                return nil
            }
            var collections = [ListingsCollection]()

            for collection in values {
                if let a_collection = ListingsCollection.serialize(collection) {
                    collections.append(a_collection)
                }
            }
            return collections
        }()

        let result = ListingGroup(id: id, name: name, listingDescription: listingDescription, category: category, tips: tips, tags: tags, featuredImage: featuredImage, featuredThumbnailImage: featuredThumbnailImage, purchaseDetails: purchaseDetails, pricingBySlots: pricingBySlots, type: type, finePrint: finePrint, galleryImages: galleryImages, categoryType: categoryType, shareMessage: shareMessage, featuredLabel: featuredLabel, cancellationPolicy: cancellation, collections: collections)

        return result
    }
}

class ListingGroupTimeSlot: ListingGroup {
    let nextClassSession: ClassSession?
    let classSessions: [ClassSession]

    init(listing: ListingGroup,
         nextClassSession: ClassSession?,
         classSessions: [ClassSession]
        ) {
        self.nextClassSession = nextClassSession
        self.classSessions = classSessions
        super.init(id: listing.id, name: listing.name, listingDescription: listing.listingDescription, category: listing.category, tips: listing.tips, tags: listing.tags, featuredImage: listing.featuredImage, featuredThumbnailImage: listing.featuredThumbnailImage, purchaseDetails: listing.purchaseDetails, pricingBySlots: listing.pricingBySlots, type: listing.type, finePrint: listing.finePrint, galleryImages: listing.galleryImages, categoryType: listing.categoryType, shareMessage: listing.shareMessage, featuredLabel: listing.featuredLabel, cancellationPolicy: listing.cancellationPolicy, collections: listing.collections)
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.nextClassSession = aDecoder.decodeObjectForKey("\(ListingGroupTimeSlot.subjectLabel).nextClassSession") as? ClassSession
        guard let classSessions = aDecoder.decodeObjectForKey("\(ListingGroupTimeSlot.subjectLabel).classSessions") as? [ClassSession] else {
            return nil
        }
        self.classSessions = classSessions
        super.init(coder: aDecoder)
    }

    @objc override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(nextClassSession, forKey: "\(self.subjectLabel).nextClassSession")
        aCoder.encodeObject(classSessions, forKey: "\(self.subjectLabel).classSessions")
        super.encodeWithCoder(aCoder)
    }

}

extension ListingGroupTimeSlot {
    override class func serialize(jsonRepresentation: AnyObject?) -> ListingGroupTimeSlot? {

        guard let json = jsonRepresentation as? [String : AnyObject] else { return nil }

        // Properties to initialize (copy from the object being serilized)

        guard let listing = ListingGroup.serialize(json) else { return nil}

        let nextClassSession = { () -> ClassSession? in
            if let value = json["next_available_class_session"] {
                return ClassSession.serialize(value)
            } else {
                return nil
            }
        }()

        let classSessions = { () -> [ClassSession] in
            var classSessions = [ClassSession]()
            if let value = json["class_sessions"] as? [AnyObject] {
                for representation in value {
                    if let classSession = ClassSession.serialize(representation) {
                        classSessions.append(classSession)
                    }
                }
            }
            return classSessions
        }()

        let result = ListingGroupTimeSlot(listing: listing, nextClassSession: nextClassSession, classSessions: classSessions)

        return result
    }
}

class ListingGroupOpenVoucher: ListingGroup {
    let voucherDetail: VoucherDetail?

    init(listing: ListingGroup,
         voucherDetail: VoucherDetail?
        ) {
        self.voucherDetail = voucherDetail
        super.init(id: listing.id, name: listing.name, listingDescription: listing.listingDescription, category: listing.category, tips: listing.tips, tags: listing.tags, featuredImage: listing.featuredImage, featuredThumbnailImage: listing.featuredThumbnailImage, purchaseDetails: listing.purchaseDetails, pricingBySlots: listing.pricingBySlots, type: listing.type, finePrint: listing.finePrint, galleryImages: listing.galleryImages, categoryType: listing.categoryType, shareMessage: listing.shareMessage, featuredLabel: listing.featuredLabel, cancellationPolicy: listing.cancellationPolicy, collections: listing.collections)
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.voucherDetail = aDecoder.decodeObjectForKey("\(ListingGroupOpenVoucher.subjectLabel).voucherDetail") as? VoucherDetail
        super.init(coder: aDecoder)
    }

    @objc override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(voucherDetail, forKey: "\(self.subjectLabel).voucherDetail")
        super.encodeWithCoder(aCoder)
    }
}

extension ListingGroupOpenVoucher {
    override class func serialize(jsonRepresentation: AnyObject?) -> ListingGroupOpenVoucher? {

        guard let json = jsonRepresentation as? [String : AnyObject] else { return nil }

        guard let listing = ListingGroup.serialize(json) else { return nil}

        let detailsValue = json["voucher_detail"] as? [String : AnyObject], voucherDetails = VoucherDetail.serialize(detailsValue)

        let result = ListingGroupOpenVoucher(listing: listing, voucherDetail: voucherDetails)

        return result
    }
}
