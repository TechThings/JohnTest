//
//  ListingTimeSlot.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol ListingTimeSlotType: ListingType {
    var nextClassSession: ClassSession? { get }
    var classSessions: [ClassSession] { get }
}

class ListingTimeSlot: Listing, ListingTimeSlotType {
    let nextClassSession: ClassSession?
    let classSessions: [ClassSession]

    init(listing: ListingType,
         nextClassSession: ClassSession?,
         classSessions: [ClassSession]
        ) {
        self.nextClassSession = nextClassSession
        self.classSessions = classSessions

        super.init(id: listing.id, name: listing.name, listingDescription: listing.listingDescription, category: listing.category, tips: listing.tips, tags: listing.tags, featuredImage: listing.featuredImage, featuredThumbnailImage: listing.featuredThumbnailImage, company: listing.company, outlet: listing.outlet, purchaseDetails: listing.purchaseDetails, pricingBySlots: listing.pricingBySlots, option: listing.option, finePrint: listing.finePrint, whatYouGet: listing.whatYouGet, galleryImages: listing.galleryImages, categoryType: listing.categoryType, shareMessage: listing.shareMessage, featuredLabel: listing.featuredLabel, cancellationPolicy: listing.cancellationPolicy, collections: listing.collections, showCancellation: listing.showCancellationPolicy, showFavePromise: listing.showFavePromise, totalRedeemableOutlets: listing.totalRedeemableOutlets)
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.nextClassSession = aDecoder.decodeObjectForKey("\(ListingTimeSlot.subjectLabel).nextClassSession") as? ClassSession
        self.classSessions = aDecoder.decodeObjectForKey("\(ListingTimeSlot.subjectLabel).classSessions") as! [ClassSession]
        super.init(coder: aDecoder)
    }

    @objc override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(nextClassSession, forKey: "\(self.subjectLabel).nextClassSession")
        aCoder.encodeObject(classSessions, forKey: "\(self.subjectLabel).classSessions")
        super.encodeWithCoder(aCoder)
    }

}

extension ListingTimeSlot {
    override class func serialize(jsonRepresentation: AnyObject?) -> ListingTimeSlot? {

        guard let json = jsonRepresentation as? [String : AnyObject] else { return nil }

        // Properties to initialize (copy from the object being serilized)

        guard let listing = Listing.serialize(json) else { return nil}

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

        let result = ListingTimeSlot(listing: listing, nextClassSession: nextClassSession, classSessions: classSessions)

        return result
    }
}
