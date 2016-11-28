//
//  Redemption.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

enum PaymentStatus: String {
    case Successful = "successful"
}
final class Redemption {

    let code: String
    let success: Bool
    let errorMessage: String?

    init(
        code: String
        , success: Bool
        , errorMessage: String?
        ) {
        self.errorMessage = errorMessage
        self.success = success
        self.code = code
    }
}

extension Redemption: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> Redemption? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let code = json["redemption_code"] as? String else {return nil}
        guard let success = json["success"] as? Bool else {return nil}

        var errorMessage: String? = nil
        if let message = json["error_message"] as? String {
            if message.characters.count > 0 { errorMessage = message }
        }

        let result = Redemption(
            code: code
            , success: success
            , errorMessage: errorMessage
        )
        return result
    }
}
