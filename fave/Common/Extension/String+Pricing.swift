//
//  String+Pricing.swift
//  FAVE
//
//  Created by Michael Cheah on 7/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

extension String {
    // We are assuming US/UK Currency Format
    private var PRICE_REGEX_FRONT: NSRegularExpression? {
        guard let expression = try? NSRegularExpression(pattern: "^([^0-9]*)([0-9]+)(\\.[0-9]{1,3})?$", options: .CaseInsensitive)
        else {
            return nil
        }

        return expression
    }

    private var PRICE_REGEX_BACK: NSRegularExpression? {
        guard let expression = try? NSRegularExpression(pattern: "^([0-9]+)(\\.[0-9][0-9])?([^0-9]*)$", options: .CaseInsensitive)
        else {
            return nil
        }

        return expression
    }

    func pricingInDecimal() -> NSDecimalNumber? {
        if let result = matchFrontCurrencyString(self) {
            return result
        } else if let result = matchBackCurrencyString(self) {
            return result
        } else {
            return nil
        }
    }

    private func matchFrontCurrencyString(price: String) -> NSDecimalNumber? {
        let trimmedString = price.stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString(",", withString: "")
        let nsTrimmedString = NSString(string: trimmedString)

        if let matches = PRICE_REGEX_FRONT?.matchesInString(trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count)) {
            if matches.count == 1 && matches.first?.numberOfRanges == 4 {
                let match = matches[0]

                var currency: String?
                var dollar: String?
                var cents: String?

                if (match.rangeAtIndex(1).location != NSNotFound) {
                    currency = nsTrimmedString.substringWithRange(match.rangeAtIndex(1))
                }

                if (match.rangeAtIndex(2).location != NSNotFound) {
                    dollar = nsTrimmedString.substringWithRange(match.rangeAtIndex(2))
                }

                if (match.rangeAtIndex(3).location != NSNotFound) {
                    cents = nsTrimmedString.substringWithRange(match.rangeAtIndex(3))
                }

                guard let dollar_unwrapped = dollar,
                let _ = currency else {
                    return nil
                }

                guard let result = {
                    _ -> (NSDecimalNumber?) in
                    if let cents_unwrapped = cents {
                        return NSDecimalNumber(string: dollar_unwrapped + cents_unwrapped)
                    } else {
                        return NSDecimalNumber(string: dollar_unwrapped)
                    }
                }() where result != NSDecimalNumber.notANumber() else {
                    return nil
                }

                return result
            }
        }

        return nil
    }

    private func matchBackCurrencyString(price: String) -> NSDecimalNumber? {
        let trimmedString = price.stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString(",", withString: "")
        let nsTrimmedString = NSString(string: trimmedString)

        if let matches = PRICE_REGEX_BACK?.matchesInString(trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count)) {
            if matches.count == 1 && matches.first?.numberOfRanges == 4 {
                let match = matches[0]

                var currency: String?
                var dollar: String?
                var cents: String?

                if (match.rangeAtIndex(3).location != NSNotFound) {
                    currency = nsTrimmedString.substringWithRange(match.rangeAtIndex(3))
                }

                if (match.rangeAtIndex(1).location != NSNotFound) {
                    dollar = nsTrimmedString.substringWithRange(match.rangeAtIndex(1))
                }

                if (match.rangeAtIndex(2).location != NSNotFound) {
                    cents = nsTrimmedString.substringWithRange(match.rangeAtIndex(2))
                }

                guard let dollar_unwrapped = dollar,
                let _ = currency else {
                    return nil
                }

                guard let result = {
                    _ -> (NSDecimalNumber?) in
                    if let cents_unwrapped = cents {
                        return NSDecimalNumber(string: dollar_unwrapped + cents_unwrapped)
                    } else {
                        return NSDecimalNumber(string: dollar_unwrapped)
                    }
                }() where result != NSDecimalNumber.notANumber() else {
                    return nil
                }

                return result
            }
        }

        return nil
    }
}
