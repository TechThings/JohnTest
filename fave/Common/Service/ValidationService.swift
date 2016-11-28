//
//  ValidationService.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Validator

protocol ValidationService {

    func validateEmail(text: String) -> ValidationResult
}

final class ValidationServiceDefault: Service, ValidationService {

    init() {
        super.init()
    }

    private let EmailRule = ValidationRulePattern(pattern: .EmailAddress, failureError: ValidationServiceError.EmailInvalid)

    func validateEmail(text: String) -> ValidationResult {
        return text.validate(rule: EmailRule)
    }

}

// MARK:- FAVE Specific
extension ValidationServiceDefault {
}

enum ValidationServiceError: ValidationErrorType {
    case EmailInvalid
    case NameInvalid

    var message: String {
        switch self {
        case .NameInvalid:
            return NSLocalizedString("envalid_name", comment: "")
        case .EmailInvalid:
            return NSLocalizedString("envalid_email", comment: "")
        }
    }
}
