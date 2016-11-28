//
//  Model.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

enum ReservationState: String {
    case Confirmed = "confirmed"
    case Cancelled = "cancelled"
    case ClassCancelled = "class_cancelled"
    case Expired = "expired"
    case Redeemed = "redeemed"
    case PendingPayment = "pending_payment"
    case PaymentProcessing = "payment_processing"

    var UIString: String {
        switch self {
        case .Confirmed: return "Confirmed"
        case .Cancelled: return "Cancelled"
        case .Expired: return "Expired"
        case .ClassCancelled: return "Class cancelled"
        case .Redeemed: return "Redeemed"
        case .PendingPayment: return "Pending payment"
        case .PaymentProcessing: return "Payment processing"
        }
    }
}

final class Reservation: NSObject {
    let reservationFromDateTime: NSDate
    let reservationToDateTime: NSDate
    let listingDetails: ListingDetailsType

    var reservationState: ReservationState
    let id: Int
    let isLateToCancel: Bool
    let cancelationDeadlineDate: NSDate?
    let slotsReserved: Int
    let redemptionCode: String
    var redeemedAt: NSDate?
    let cancellable: Bool
    let receiptId: String?
    let statusTitle: String?
/* This comes from when the backend determines whether it's an open voucher or time slot  (Eagle Activity vs Eagle Session)
     */
    let reservableId: Int

/* When user buys multiple vouchers in one go, backend assigns them a reservation set id
     */
    let reservationSetId: Int
    let reservableType: String
    let totalChargedAmountUserVisible: String

    // For Payment Pending Indonesia
    let expiringAt: NSDate?

    let purchaseDetails: PurchaseDetails

    init(
        reservationFromDateTime: NSDate
        , reservationToDateTime: NSDate
        , listingDetails: ListingDetailsType
        , reservationState: ReservationState
        , id: Int
        , isLateToCancel: Bool
        , cancelationDeadlineDate: NSDate?
        , slotsReserved: Int
        , redemptionCode: String
        , redeemedAt: NSDate?
        , reservableId: Int
        , reservableType: String
        , reservationSetId: Int
        , totalChargedAmountUserVisible: String
        , expiringAt: NSDate?
        , cancellable: Bool
        , receiptId: String?
        , purchaseDetails: PurchaseDetails
        , statusTitle: String?
        ) {
        self.reservationFromDateTime = reservationFromDateTime
        self.reservationToDateTime = reservationToDateTime
        self.listingDetails = listingDetails
        self.id = id
        self.isLateToCancel = isLateToCancel
        self.cancelationDeadlineDate = cancelationDeadlineDate
        self.slotsReserved = slotsReserved
        self.redemptionCode = redemptionCode
        self.redeemedAt = redeemedAt
        self.reservableId = reservableId
        self.reservableType = reservableType
        self.reservationSetId = reservationSetId
        self.totalChargedAmountUserVisible = totalChargedAmountUserVisible
        self.reservationState = reservationState
        self.expiringAt = expiringAt
        self.cancellable = cancellable
        self.receiptId = receiptId
        self.purchaseDetails = purchaseDetails
        self.statusTitle = statusTitle
    }
}

extension Reservation: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> Reservation? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties initialization

        guard let reservationState = { () -> ReservationState? in
            guard let value = json["status"] as? String else { return nil }
            return ReservationState(rawValue: value)
            }() else { return nil }

        guard let id = json["id"] as? Int else {return nil}
        guard let isLateToCancel = json["is_late_to_cancel"] as? Bool else {return nil}
        let cancelationDeadlineDate = { () -> NSDate? in
            guard let value = json["early_cancellation_date"] as? String else { return nil }
            return value.RFC3339DateTime
            }()
        guard let slotsReserved = json["slots_reserved"] as? Int else {return nil}
        guard let redemptionCode = json["redemption_code"] as? String else {return nil}
        print("redemptionCode = \(redemptionCode)")
        let redeemedAt = { () -> NSDate? in
            guard let value = json["redeemed_at"] as? String else { return nil }
            return value.RFC3339DateTime
            }()
        guard let reservableId = json["reservable_id"] as? Int else {return nil}
        guard let reservableType = json["reservable_type"] as? String else {return nil}
        guard let reservationSetId = json["reservation_set_id"] as? Int else {return nil}
        guard let totalChargedAmountUserVisible = json["total_charge_amount"] as? String else {return nil}

        guard let reservationFromDateTime = { () -> NSDate? in
            let value = json["start_datetime"] as? String
            return value?.RFC3339DateTime
            }() else {return nil}

        guard let reservationToDateTime = { () -> NSDate? in
            let value = json["end_datetime"] as? String
            return value?.RFC3339DateTime
            }() else {return nil}

        // Properties to initialize (copy from the object being serilized)
        guard let  listingDetails: ListingDetailsType = { () -> ListingDetailsType? in
            guard let listingJson = json["listing"] as? [String: AnyObject] else { return nil}
            if let listingType = listingJson["listing_type"] as? String {
                if listingType == ListingOption.OpenVoucher.rawValue {
                    return ListingOpenVoucherDetails.serialize(listingJson)
                }
                if listingType == ListingOption.TimeSlot.rawValue {
                    return ListingTimeSlotDetails.serialize(listingJson)
                }
            }
            return nil

        }() else {return nil}

        let expiringAt = { () -> NSDate? in
            guard let value = json["expiring_at"] as? String else { return nil }
            return value.RFC3339DateTime
        }()

        let cancellable = { () -> Bool in
            guard let cancel = json["cancellable"] as? Bool else { return false }
            return cancel
        }()

        var receipt: String?
        if let transactionDetail = json["transaction_details"] as? [String: AnyObject] {
            guard let receiptId = transactionDetail["receipt_id"] as? String else { return nil }
            receipt = receiptId
        }

        guard let purchaseDetails = PurchaseDetails.serialize(json["purchase_details"]) else { return nil }

        let statusTitle = { () -> String? in
            guard let status = json["status_title"] as? String else { return nil }
            return status
        }()

        let result = Reservation(
            reservationFromDateTime: reservationFromDateTime
            , reservationToDateTime: reservationToDateTime
            , listingDetails: listingDetails
            , reservationState: reservationState
            , id: id, isLateToCancel: isLateToCancel
            , cancelationDeadlineDate: cancelationDeadlineDate
            , slotsReserved: slotsReserved
            , redemptionCode: redemptionCode
            , redeemedAt: redeemedAt
            , reservableId: reservableId
            , reservableType: reservableType
            , reservationSetId: reservationSetId
            , totalChargedAmountUserVisible: totalChargedAmountUserVisible
            , expiringAt: expiringAt
            , cancellable: cancellable
            , receiptId: receipt
            , purchaseDetails: purchaseDetails
            , statusTitle: statusTitle
        )
        return result
    }
}
