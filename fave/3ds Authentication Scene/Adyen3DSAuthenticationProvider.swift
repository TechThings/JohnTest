//
//  Adyen3DSAuthenticationAPI.swift
//  FAVE
//
//  Created by Light Dream on 15/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import WebKit

protocol Adyen3DSAuthenticationProvider {
    func getHTMLString(withData adyenData: AdyenAuth3DS) -> Observable<String>
}

final class Adyen3DSAuthenticationProviderDefault: Provider, Adyen3DSAuthenticationProvider {

    private let networkService: NetworkService
    private var webview: WKWebView?
    private let webviewHTMLResonseSubject: PublishSubject<String> = PublishSubject()
    private var adyenData: AdyenAuth3DS! // this will only be access if you make a call to `getHTMLString` which will set this and then the webview so the force unwrap option is valid.

    init(networkService: NetworkService = networkServiceDefault) {
        self.networkService = networkService
    }

    func getHTMLString(withData adyenData: AdyenAuth3DS) -> Observable<String> {

        self.adyenData = adyenData

        self.webview = WKWebView(frame: CGRect.zero)
        webview?.navigationDelegate = self
        self.webview?.loadHTMLString("<html></html>", baseURL: nil)

        return webviewHTMLResonseSubject
    }
}

extension Adyen3DSAuthenticationProviderDefault: WKNavigationDelegate {
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // NOTE: This will never be called unless `getHTML` method was called, and that means requestPayload is always not nil.
        let url = NSURL(string: self.adyenData.issuerURL)!
        let params = self.adyenData.deserialize()
        let mutableURLRequest = try! self.networkService.URLRequest(method: .POST, URL: url, parameters: params, encoding: .URL, headers: nil)
        mutableURLRequest.setValue(nil, forHTTPHeaderField: "Cookie")

        let session = NSURLSession.sharedSession()
        var dataTask: NSURLSessionDataTask?

        self.webview?.evaluateJavaScript("navigator.userAgent") { (userAgent: AnyObject?, error: NSError?) in
            let userAgentString = userAgent as? String
            if error != nil {
                self.webviewHTMLResonseSubject.onError(error!)
                return
            }

            mutableURLRequest.setValue(userAgentString!, forHTTPHeaderField: "User-Agent")

            dataTask = session.dataTaskWithRequest(mutableURLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
                if (error != nil) {
                    print(error)
                    self?.webviewHTMLResonseSubject.onError(error!)
                } else {
                    let httpResponse = response as? NSHTTPURLResponse
                    print(httpResponse)

                    let stringResponse = String(data: data!, encoding: NSUTF8StringEncoding)!
                    // Maybe we should guard this thing... although i don't think so
                    print(stringResponse)
                    self?.webviewHTMLResonseSubject.onNext(stringResponse)
                    self?.webviewHTMLResonseSubject.onCompleted()
                    self?.webview = nil // get rid of the temp var, no need for it anymore.
                    print()
                }
            })

            dataTask?.resume()

        }

    }
}
