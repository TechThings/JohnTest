//
//  PaymentMethod.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class PaymentMethod: NSObject {

    let kind: String?
    let identifier: String
    let primary: Bool

    init(kind: String?
        , identifier: String
        , primary: Bool) {
        self.kind = kind
        self.identifier = identifier
        self.primary = primary
    }
}

extension PaymentMethod: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> PaymentMethod? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        let kind = json["kind"] as? String

        guard let identifier = json["identifier"] as? String else { return nil }

        guard let primary = json["primary"] as? Bool else { return nil }

        let result = PaymentMethod(
                kind: kind,
                identifier: identifier,
                primary: primary)
        return result
    }
}
