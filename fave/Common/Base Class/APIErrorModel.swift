//
//  APIErrorModel.swift
//  fave
//
//  Created by Michael Cheah on 7/15/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

class APIErrorModel: NSObject {

    let status: Int
    let errors: [APIError]

    init(status: Int, errors: [APIError]) {
        self.status = status
        self.errors = errors
    }

    var userVisibleErrorMessage: String {
        guard let error = errors.first else { return NSLocalizedString("msg_something_wrong", comment: "") }
        return error.message
    }
}

extension APIErrorModel: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> APIErrorModel? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        guard let status = json["status"] as? Int else {
            return nil
        }
        var errors = [APIError]()

        guard let value = json["errors"] as? [AnyObject] else {
            return nil
        }

        for representation in value {
            guard let error = APIError.serialize(representation) else { return nil }
            errors.append(error)
        }

        let result = APIErrorModel(status: status, errors: errors)
        return result
    }
}

final class APIError: NSObject {
    let attribute: String
    let message: String

    init(attribute: String, message: String) {
        self.attribute = attribute
        self.message = message
    }
}

extension APIError: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> APIError? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        guard let attribute = json["attribute"] as? String else {
            return nil
        }
        guard let message = json["message"] as? String else {
            return nil
        }

        let result = APIError(attribute: attribute, message: message)
        return result
    }
}

/*
{
    "status": 400,
    "errors": [
        {
            "attribute": "reservation",
            "message": "This offer has already been fully reserved."
        },
        {
            "attribute": "reservation",
            "message": "Exceeded the offer capacity"
        }
    ]
}
*/
