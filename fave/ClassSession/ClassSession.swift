//
//  ClassSession.swift
//  KFIT
//
//  Created by Nazih Shoura on 14/03/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

final class ClassSession: NSObject, NSCoding {
    let id: Int
    let startDateTime: NSDate
    let endDateTime: NSDate
    let remainingSlots: Int
    let earlyCancellationDate: NSDate

    init(id: Int, startDateTime: NSDate, endDateTime: NSDate, remainingSlots: Int, earlyCancellationDate: NSDate) {
        self.id = id
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.remainingSlots = remainingSlots
        self.earlyCancellationDate = earlyCancellationDate
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObjectForKey("\(literal.ClassSession).id") as? Int else { return nil }
        self.id = id

        guard let startDateTime = aDecoder.decodeObjectForKey("\(literal.ClassSession).startDateTime") as? NSDate else { return nil }
        self.startDateTime = startDateTime

        guard let endDateTime = aDecoder.decodeObjectForKey("\(literal.ClassSession).endDateTime") as? NSDate else { return nil }
        self.endDateTime = endDateTime

        guard let remainingSlots = aDecoder.decodeObjectForKey("\(literal.ClassSession).remainingSlots") as? Int else { return nil }
        self.remainingSlots = remainingSlots

        guard let earlyCancellationDate = aDecoder.decodeObjectForKey("\(literal.ClassSession).earlyCancellationDate") as? NSDate else { return nil }
        self.earlyCancellationDate = earlyCancellationDate
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: "\(literal.ClassSession).id")
        aCoder.encodeObject(startDateTime, forKey: "\(literal.ClassSession).startDateTime")
        aCoder.encodeObject(endDateTime, forKey: "\(literal.ClassSession).endDateTime")
        aCoder.encodeInteger(remainingSlots, forKey: "\(literal.ClassSession).remainingSlots")
        aCoder.encodeObject(earlyCancellationDate, forKey: "\(literal.ClassSession).earlyCancellationDate")
    }
}

extension ClassSession: Serializable {
    final class func serialize(jsonRepresentation: AnyObject?) -> ClassSession? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize
        var id: Int?
        var startDateTime: NSDate?
        var endDateTime: NSDate?
        var remainingSlots: Int?
        var earlyCancellationDate: NSDate?

        // Properties initialization
        if let value = json["id"] as? Int {
            id = value
        }

        if let value = json["start_datetime"] as? String {
            startDateTime = value.RFC3339DateTime
        }

        if let value = json["end_datetime"] as? String {
            endDateTime = value.RFC3339DateTime
        }

        if let value = json["remaining_slots"] as? Int {
            remainingSlots = value
        }

        if let value = json["early_cancellation_date"] as? String {
            earlyCancellationDate = value.RFC3339DateTime
        }

        // Verify properties and initialize object
        if let id = id
            , startDateTime = startDateTime
            , endDateTime = endDateTime
            , remainingSlots = remainingSlots
            , earlyCancellationDate = earlyCancellationDate {
            let result = ClassSession(id: id, startDateTime: startDateTime, endDateTime: endDateTime, remainingSlots: remainingSlots, earlyCancellationDate: earlyCancellationDate)
            return result
        }
        return nil
    }
}
