//
//  PendingAction.swift
//  FAVE
//
//  Created by Thanh KFit on 8/23/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

enum PendingNotificationType: String {
    case Purchase = "purchase"
    case Invite = "invite"
}

final class PendingNotification {

    let type: PendingNotificationType
    let buttonText: String
    let reservationId: Int?

    init(
        type: PendingNotificationType
        , buttonText: String
        , reservationId: Int?
        ) {
        self.type = type
        self.buttonText = buttonText
        self.reservationId = reservationId
    }
}

extension PendingNotification: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> PendingNotification? {
        guard let json = jsonRepresentation?["pending_action"] as? [String : AnyObject] else {
            return nil
        }

        guard let action = json["action"] as? [String: AnyObject] else {return nil}

        guard let typeString = action["type"] as? String, let type = PendingNotificationType(rawValue: typeString) else {return nil}

        guard let buttonText = action["button_text"] as? String else {return nil}

        let reservationId = action["reservation_id"] as? Int

        let result = PendingNotification (
            type: type
            , buttonText: buttonText
            , reservationId: reservationId
        )
        return result
    }
}
