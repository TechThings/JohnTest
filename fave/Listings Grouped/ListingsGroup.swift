//
//  ListingsGroup.swift
//  FAVE
//
//  Created by Thanh KFit on 10/9/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

class ListingsGroup {

    let outlet: Outlet
    let rowDisplayNumber: Int
    let totalOffers: Int
    let listings: [ListingGroup]

    init(
        outlet: Outlet
        , rowDisplayNumber: Int
        , totalOffers: Int
        , listings: [ListingGroup]
        ) {
        self.outlet = outlet
        self.rowDisplayNumber = rowDisplayNumber
        self.totalOffers = totalOffers
        self.listings = listings
    }
}

extension ListingsGroup: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ListingsGroup? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let outlet = Outlet.serialize(json) else {
            return nil
        }

        guard var rowDisplayNumber = json["row_display_number"] as? Int else {
            return nil
        }

        guard let totalOffers = json["total_offers"] as? Int else {
            return nil
        }

        var listings = [ListingGroup]()

        if let listingsJson = json["offers"] as? [AnyObject] {
            for representation in listingsJson {
                if let listingType = representation["listing_type"] as? String {
                    if listingType == ListingOption.OpenVoucher.rawValue {
                        if let listing = ListingGroupOpenVoucher.serialize(representation) {
                            listings.append(listing)
                        }
                    }
                    if listingType == ListingOption.TimeSlot.rawValue {
                        if let listing = ListingGroupTimeSlot.serialize(representation) {
                            listings.append(listing)
                        }
                    }
                }
            }
        }
        if listings.isEmpty { return nil }

        // Exeption: free crash when can not serialize data from stupid backend
        rowDisplayNumber = min(rowDisplayNumber, listings.count)

        let result = ListingsGroup(outlet: outlet, rowDisplayNumber: rowDisplayNumber, totalOffers: totalOffers, listings: listings)
        return result
    }
}
