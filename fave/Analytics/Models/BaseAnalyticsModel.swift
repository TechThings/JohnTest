//
// Created by Michael Cheah on 7/27/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation

class BaseAnalyticsModel {
    func addReservationProperties(event: AnalyticsEvent, reservation: Reservation) -> AnalyticsEvent {
        let listing = reservation.listingDetails
        let featured = listing.tags.contains("Featured on Fave")

        event.addProperty("Reservation_ID", value: reservation.id)
        .addProperty("Reservation_Set_ID", value: reservation.reservationSetId)
        .addProperty("Reservable_ID", value: reservation.reservableId)
        .addProperty("Reservable_Type", value: reservation.reservableType)
        .addProperty("Activity_Name", value: listing.name)
        .addProperty("Outlet_Name", value: listing.outlet.name)
        .addProperty("Category", value: listing.category.name)
        .addProperty("Category_Type", value: listing.categoryType)
        .addProperty("Tags", value: listing.tags)
        .addProperty("Special", value: featured)
        .addProperty("Rating", value: listing.company.averageRating)
        .addProperty("Type", value: listing.option.rawValue)
        .addProperty("Quantity", value: reservation.slotsReserved)

        if let town = listing.outlet.town {
            event.addProperty("Outlet_Town", value: town)
        }

        if let distanceKM = listing.outlet.distanceKM {
            event.addProperty("Distance", value: distanceKM)
        }

        if let totalChargedAmount = reservation.totalChargedAmountUserVisible.pricingInDecimal() {
            event.addProperty("Price", value: totalChargedAmount.doubleValue)
        }

        return event
    }

    func addListingProperties(event: AnalyticsEvent, listing: ListingType) -> AnalyticsEvent {
        let featured = listing.tags.contains("Featured on Fave")

        event.addProperty("Activity_ID", value: listing.id)
        .addProperty("Activity_Name", value: listing.name)
        .addProperty("Outlet_Name", value: listing.outlet.name)
        .addProperty("Category", value: listing.category.name)
        .addProperty("Category_Type", value: listing.categoryType)
        .addProperty("Tags", value: listing.tags)
        .addProperty("Special", value: featured)
        .addProperty("Rating", value: listing.company.averageRating)
        .addProperty("Type", value: listing.option.rawValue)

        if let discountedPrice = listing.purchaseDetails.discountPriceUserVisible.pricingInDecimal() {
            event.addProperty("Price", value: discountedPrice.doubleValue)
        }

        if let town = listing.outlet.town {
            event.addProperty("Outlet_Town", value: town)
        }

        if let distanceKM = listing.outlet.distanceKM {
            event.addProperty("Distance", value: distanceKM)
        }

        return event
    }
}
