//
//  NSError.swift
//  FAVE
//
//  Created by Nazih Shoura on 11/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

extension NSError {
    final class var unknownError: NSError {
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("msg_something_wrong", comment:"")
        ]

        let error = NSError(domain: "NSError", code: 0, userInfo: userInfo)

        return error
    }
}
