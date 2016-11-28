//
//  DescribableError.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/24/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol DescribableError: ErrorType {
    var description: String { get }
    var userVisibleDescription: String { get }
}

extension NSError {
    func toDescribableError() -> DescribableError {
        struct DescribableErrorStruct: DescribableError {
            let description: String
            let userVisibleDescription: String
            init(description: String, userVisibleDescription: String) {
                self.description = description
                self.userVisibleDescription = userVisibleDescription
            }
        }
        var description: String = ""
        if let localDescription = self.userInfo[NSLocalizedDescriptionKey] {
            description = "\(localDescription)"
        }

        let describableError = DescribableErrorStruct(
            description: description
            , userVisibleDescription: NSLocalizedString("msg_something_wrong", comment: "")
        )
        return describableError
    }
}

extension DescribableError {
    func toNSError() -> NSError {
        let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: self.userVisibleDescription]
        let error = NSError(domain: "", code: 0, userInfo: userInfo)
        return error
    }
}
