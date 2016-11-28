//
//  Result.swift
//
//  Created by Nazih Shoura on 31/05/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

enum Result<ValueType> {
    case Success(ValueType)
    case Failure(ErrorType)

    /// Returns `true` if the result is a success, `false` otherwise.
    var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        default:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    var isFailure: Bool {
        switch self {
        case .Failure:
            return true
        default:
            return false
        }
    }

    /// Returns the associated value if the result is a success, `nil` otherwise.
    var value: ValueType? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
}
