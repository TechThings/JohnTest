//
//  VoucherDetail.swift
//  fave
//
//  Created by Michael Cheah on 7/9/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class VoucherDetail: NSObject, NSCoding {

    let validityStartDateTime: NSDate
    let validityEndDateTime: NSDate
    let purchaseSlots: Int
    let refund_end_datetime: NSDate

    init(validityStartDateTime: NSDate,
         validityEndDateTime: NSDate,
         purchaseSlots: Int,
         refund_end_datetime: NSDate
    ) {
        self.validityStartDateTime = validityStartDateTime
        self.validityEndDateTime = validityEndDateTime
        self.purchaseSlots = purchaseSlots
        self.refund_end_datetime = refund_end_datetime
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        guard let validityStartDateTime = aDecoder.decodeObjectForKey("\(VoucherDetail.subjectLabel).validityStartDateTime") as? NSDate else { return nil }
        self.validityStartDateTime = validityStartDateTime

        guard let validityEndDateTime = aDecoder.decodeObjectForKey("\(VoucherDetail.subjectLabel).validityEndDateTime") as? NSDate else { return nil }
        self.validityEndDateTime = validityEndDateTime

        guard let purchaseSlots = aDecoder.decodeObjectForKey("\(VoucherDetail.subjectLabel).purchaseSlots") as? Int else { return nil }
        self.purchaseSlots = purchaseSlots

        guard let refund_end_datetime = aDecoder.decodeObjectForKey("\(VoucherDetail.subjectLabel).refund_end_datetime") as? NSDate else { return nil }
        self.refund_end_datetime = refund_end_datetime
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(validityStartDateTime, forKey: "\(self.subjectLabel).validityStartDateTime")
        aCoder.encodeObject(validityEndDateTime, forKey: "\(self.subjectLabel).validityEndDateTime")
        aCoder.encodeInteger(purchaseSlots, forKey: "\(self.subjectLabel).purchaseSlots")
        aCoder.encodeObject(refund_end_datetime, forKey: "\(self.subjectLabel).refund_end_datetime")
    }
}

extension VoucherDetail: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> VoucherDetail? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        guard let startValue = json["start_datetime"] as? String, let startDateTime = startValue.RFC3339DateTime else {
            return nil
        }

        guard let endValue = json["end_datetime"] as? String, let endDateTime = endValue.RFC3339DateTime else {
            return nil
        }

        guard let slots = json["purchase_slots"] as? Int else {
            return nil
        }

        guard let refund_end_datetime_string = json["refund_end_datetime"] as? String, let refund_end_datetime = refund_end_datetime_string.RFC3339DateTime else {
            return nil
        }

        let result = VoucherDetail(validityStartDateTime: startDateTime, validityEndDateTime: endDateTime, purchaseSlots: slots, refund_end_datetime: refund_end_datetime)
        return result
    }
}
