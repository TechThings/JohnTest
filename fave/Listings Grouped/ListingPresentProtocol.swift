//
//  ListingUserVisible.swift
//  FAVE
//
//  Created by Thanh KFit on 10/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol ListingUserVisible: NSCoding {
    var id: Int { get }
    var name: String { get }
    var featuredImage: NSURL? { get }
    var featuredThumbnailImage: NSURL? { get }
    var purchaseDetails: PurchaseDetails { get }
}
