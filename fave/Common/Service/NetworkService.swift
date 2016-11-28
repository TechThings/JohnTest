//
//  Network.swift
//
//  Created by Nazih Shoura on 08/05/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkService: Cachable {
    /**
     Default session configuration object. The manager is configured with
     ```
     HTTPAdditionalHeaders = ["User-Agent": DefaultAPI.userAgent]
     ```
     
     - author: Nazih Shoura
     */
    var managerWithDefaultConfiguration: Manager { get }

    /**
     A session configuration object that allows HTTP and HTTPS uploads or downloads to be performed in the background. Identifier is "com.kfit.KFIT"
     ```
     HTTPAdditionalHeaders = ["User-Agent": DefaultAPI.userAgent]
     ```
     
     - author: Nazih Shoura
     */
    var managerWithBackgroundConfiguration: Manager { get }

    /**
     A session configuration that uses no persistent storage for caches, cookies, or credentials. The manager is configured with
     ```
     HTTPAdditionalHeaders = ["User-Agent": DefaultAPI.userAgent]
     ```
     
     - author: Nazih Shoura
     */
    var managerWithEphemeralConfiguration: Manager { get }

    /**
     The userAgent that the sessions are configured with.
     ```
     HTTPAdditionalHeaders = ["User-Agent": DefaultAPI.userAgent]
     ```
     
     - author: Nazih Shoura
     */
    var userAgent: String { get }

    /**
     Creates a NSMutableURLRequest using all necessary parameters.
     
     - author: Nazih Shoura
     
     - parameter method: Alamofire method object
     - parameter URLString: An object adopting `URLStringConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     - returns: An instance of `NSMutableURLRequest`
     */
    func URLRequest(
            method method: Alamofire.Method
            , URL: NSURL
            , parameters: [String:AnyObject]?
            , encoding: ParameterEncoding
            , headers: [String:String]?)
    throws -> NSMutableURLRequest

    func setCookiesFromResponse(response: NSHTTPURLResponse)

    static var cookie: String? { get }

    var sessionExist: Bool { get }
}

final class NetworkServiceDefault: Service, NetworkService {

    let managerWithDefaultConfiguration: Manager

    let managerWithBackgroundConfiguration: Manager

    let managerWithEphemeralConfiguration: Manager

    let userAgent: String

    static var cookie: String?

    init() {

        let userAgent: String = {
            let infoDict = NSBundle.mainBundle().infoDictionary
            let appVersion = infoDict!["CFBundleShortVersionString"]!
            let buildNumber = infoDict!["CFBundleVersion"]!
            let currentDeviceModel = UIDevice.currentDevice().model
            let currentDeviceSystemVersion = UIDevice.currentDevice().systemVersion
            let userAgent = "FAVE-Global/v\(appVersion)-\(buildNumber) (\(currentDeviceModel);iOS \(currentDeviceSystemVersion))"

            return userAgent
        }()

        self.userAgent = userAgent

        managerWithEphemeralConfiguration = {
            let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
            configuration.HTTPAdditionalHeaders = ["User-Agent": userAgent]
            return Manager(configuration: configuration)
        }()

        managerWithBackgroundConfiguration = {
            let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.kfit.FAVE")
            configuration.HTTPAdditionalHeaders = ["User-Agent": userAgent]
            return Manager(configuration: configuration)
        }()

        managerWithDefaultConfiguration = {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = ["User-Agent": userAgent]
            return Manager(configuration: configuration)
        }()

        super.init()

        loadSession()

        app.logoutSignal.subscribeNext {
            _ in
            NetworkServiceDefault.clearCacheForCookies()
        }.addDisposableTo(disposeBag)
    }

    func URLRequest(
            method method: Alamofire.Method
            , URL: NSURL
            , parameters: [String:AnyObject]? = nil
            , encoding: ParameterEncoding = .URL
            , headers: [String:String]? = nil)
    throws -> NSMutableURLRequest {
        var mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.HTTPShouldHandleCookies = false

        if let headers = headers {
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }

        if let cookie = NetworkServiceDefault.cookie {
            mutableURLRequest.setValue(cookie, forHTTPHeaderField: "Cookie")
        }

        if let parameters = parameters {
            let encoded = encoding.encode(mutableURLRequest, parameters: parameters)
            if let error = encoded.1 {
                throw error
            }
            mutableURLRequest = encoded.0
        }

        loggerDefault.log(mutableURLRequest, parameters: parameters, headers: headers, cookie: NetworkServiceDefault.cookie)

        return mutableURLRequest
    }

    func setCookiesFromResponse(response: NSHTTPURLResponse) {
        if let headerFields = response.allHeaderFields as? [String:String] {
            guard let cookie = headerFields["Set-Cookie"] else {
                return
            }

            NetworkServiceDefault.cookie = cookie
            NetworkServiceDefault.cache(cookie)
        }
    }

    var sessionExist: Bool {
        guard let cookie = NSUserDefaults
        .standardUserDefaults()
        .objectForKey(literal.Cookie) as? String where !cookie.isEmpty
        else {
            return false
        }

        return true
    }

    func loadSession() {
        NetworkServiceDefault.cookie = NetworkServiceDefault.loadCacheForCookies()
    }
}

extension NetworkServiceDefault {
    static func cache(cookie: String) {
        NSUserDefaults.standardUserDefaults()
        .setObject(cookie, forKey: literal.Cookie)
    }

    static func loadCacheForCookies() -> String? {
        guard let cookie = NSUserDefaults.standardUserDefaults().objectForKey(literal.Cookie) as? String else {
            NetworkServiceDefault.clearCacheForCookies()
            return nil
        }

        return cookie
    }

    static func clearCacheForCookies() {
        NSUserDefaults
        .standardUserDefaults()
        .setObject(nil, forKey: literal.Cookie)
        NetworkServiceDefault.cookie = nil
    }
}
