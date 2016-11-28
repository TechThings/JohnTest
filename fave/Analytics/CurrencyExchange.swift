//
//  CurrencyExchange.swift
//  FAVE
//
//  Created by Michael Cheah on 7/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

class CurrencyExchange {
    private static let FOREX_RATE = [
            "USD": "1.000000",
            "MYR": "0.253196",
            "IDR": "0.0000759793",
            "SGD": "0.742820",
            "HKD": "0.128911",
            "TWD": "0.0311190",
            "NZD": "0.731317",
            "AUD": "0.762761",
            "PHP": "0.0211954",
            "KRW": "0.000874332",
            "JPY": "0.00956202",
            "THB": "0.0284233",
            "VND": "0.0000448408",
            "CNY": "0.149499",
            "INR": "0.0149365",
            "GBP": "1.32560",
            "EUR": "1.10867"
    ] as [String:String]

    class func toUSDollar(currencyCode: String, amount: NSDecimalNumber) -> NSDecimalNumber? {
        guard let exchangeRate = FOREX_RATE[currencyCode] else {
            // Currency Not Supported
            return nil
        }

        let exchangeRateDecimal = NSDecimalNumber(string: exchangeRate)
        if exchangeRateDecimal == NSDecimalNumber.notANumber() {
            return nil
        } else {
            return exchangeRateDecimal.decimalNumberByMultiplyingBy(amount)
        }
    }
}
