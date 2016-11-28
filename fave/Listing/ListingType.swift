//
//  ListingType.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol ListingType: NSCoding, ListingUserVisible {
    var id: Int { get }
    var name: String { get }
    var listingDescription: String? { get }
    var category: SubCategory { get }
    var tips: String? { get }
    var tags: [String] { get }
    var featuredImage: NSURL? { get }
    var featuredThumbnailImage: NSURL? { get }
    var company: Company { get }
    var outlet: Outlet { get }
    var purchaseDetails: PurchaseDetails { get }
    var pricingBySlots: [PurchaseDetails]? { get }
    var option: ListingOption { get }
    var finePrint: String? { get }
    var whatYouGet: String? { get }
    var galleryImages: [NSURL] { get }
    var categoryType: String { get }
    var shareMessage: ShareMessage? { get }
    var featuredLabel: String? { get }
    var cancellationPolicy: String? { get }
    var collections: [ListingsCollection]? { get }
    var showCancellationPolicy: Bool? {get}
    var showFavePromise: Bool? {get}
    var totalRedeemableOutlets: Int? { get }
}
