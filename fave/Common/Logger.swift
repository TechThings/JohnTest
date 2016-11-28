//
//  Logger.swift
//  FAVE
//
//  Created by Nazih Shoura on 11/6/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import Crashlytics

enum LoggingMode {
    /// Use this mode to log useful info.
    /// `info` mode logs will be written when running with Debug build configuration only.
    case info
    /// Use this mode to log errors.
    /// `error` mode logs will be written when running any build configuration and will be uploaded to online logging services.
    case error
    /// Use this mode to log newly added code. Once the code is deemed safe, change it's logging mode to `info`.
    /// `debug` mode logs will be written when running any build configuration and will be uploaded to online logging services.
    case debug

    var shouldUploadToProduction: Bool {
        #if DEBUG
            return false
        #else
            switch self {
            case .debug, .error: return true
            case .info: return false
            }
        #endif
    }
}

enum LogingTag: String {
    case adyen = "ADYEN"
    case payment = "PAYMENT"
    case veritrans = "VERITRANS"
    case brainTree = "BRAINTREE"
    case confirmReservation = "CONFIRM_RESERVATION"
    case memoryLeaks = "MEMORY_LEAKS"
    case ui = "UI"
    case apiRequest = "API_REQUEST"
}

final class Logger {
    init() {
    }

    func log(message: String
        , loggingMode: LoggingMode
        , logingTags: [LogingTag]
        , shouldShowCodeLocation: Bool = true
        , file: StaticString = #file
        , function: StaticString = #function
        , line: Int = #line) {

        let output: String = { () -> String in
            var result = "\n**********\n"

            if shouldShowCodeLocation {
                if let fileName = NSURL(string:file.stringValue)?.lastPathComponent?.componentsSeparatedByString(".").first {
                    result = result + "\(fileName)"
                } else {
                    result = result + "\(file)"
                }
                result = result + ".\(function) line \(line)"
            }
            if logingTags.contains(LogingTag.memoryLeaks) {
                result = result + "🤔 \(message)\nTags: \(logingTags.map { $0.rawValue })\n**********\n"
            } else {
                result = result + "\(message)\nTags: \(logingTags.map { $0.rawValue })\n**********\n"
            }
            return result
        }()

        log(output, loggingMode: loggingMode)
    }

    func log(error: DescribableError
        , logingTags: [LogingTag]
        ) {

        let loggingMode = LoggingMode.error

        var output = ""
        if case ResponseError.couldNotSerializeResponse(_)  = error {
            output = "\n**********\n🖕 Error\nDescription: \n\(error.description)\nTags: \(logingTags.map { $0.rawValue })\n**********\n"
        } else {
            output = "\n**********\n😰 Error\nDescription: \n\(error.description)\nTags: \(logingTags.map { $0.rawValue })\n**********\n"
        }

        log(output, loggingMode: loggingMode)
    }

    func log(request: NSURLRequest, parameters: [String:AnyObject]?, headers: [String:String]?, cookie: String?) {
        var output = "\n**********\n🙏 Requesting: \(request.description)"
        if let parameters = parameters {
            output = output + "\nWith parameters: \(parameters)"
        } else {
            output = output + "\nWith NO parameters"
        }
        if let headers = headers {
            output = output + "\nWith headers: \(headers)"
        } else {
            output = output + "\nWith NO headers"
        }
        if let cookie = cookie {
            output = output + "\nWith cookie: \(cookie)"
        } else {
            output = output + "\nWith NO cookie"
        }
        output = output + "\nTags: \(LogingTag.apiRequest.rawValue)\n**********\n"
        log(output, loggingMode: LoggingMode.info)
    }

    func log(responsePayload: ResponsePayload.Type
        , reseavedResponse: AnyObject?
        , loggingMode: LoggingMode
        , logingTags: [LogingTag]
        ) {

        let output: String = "\n**********\n😬 Response \(String(responsePayload))\nReseaved: \(reseavedResponse)\nTags: \(logingTags.map { $0.rawValue })\n**********\n"

        log(output, loggingMode: loggingMode)
    }

    private func log(output: String, loggingMode: LoggingMode) {
//        if loggingMode.shouldUploadToProduction {
//        } else {
//        }
        #if DEBUG
            print(output)
        #endif
    }

}
