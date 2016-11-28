//
//  Adyen3DSAuthenticationViewController.swift
//  FAVE
//
//  Created by Light Dream on 25/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WebKit

final class Adyen3DSAuthenticationViewController: ViewController {

    var viewModel: Adyen3DSAuthenticationViewControllerViewModel!

    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet var webViewContainer: UIView!

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()

        self.bind()

    }

    func setup() {

        let userContentController = WKUserContentController()

        userContentController.addScriptMessageHandler(self, name: "onAuthorizeCard")
        userContentController.addScriptMessageHandler(self, name: "onAuthorizePayment")

        let jsSource = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"

        let userScript  = WKUserScript(source: jsSource, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)

        userContentController.addUserScript(userScript)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        self.webView = WKWebView(frame: self.webViewContainer.bounds, configuration: configuration)

        self.webViewContainer.addSubview(webView)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
}

extension Adyen3DSAuthenticationViewController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {

        func handleError(json: [String: AnyObject]) {
            // decode error
            if let errors = json["errors"] as? [[String: AnyObject]] {
                let error: [String: String] = errors[0] as! [String: String]
                self.viewModel.result.onError(NSError(domain: "com.fave.unknown", code: 1947, userInfo: [NSLocalizedDescriptionKey: error["message"]!]))

            } else {
                self.viewModel.result.onError(NSError(domain: "com.fave.unknown", code: 1947, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("msg_something_wrong", comment: "")]))

            }
        }

        func handleAdyen(json: [String: AnyObject]) {
            if let paymentMethod = PaymentMethod.serialize(json) {
                viewModel.result.onNext(.PaymentMethods(data: [paymentMethod]))
                viewModel.result.onCompleted()
            } else {
                self.viewModel.result.onError(NSError(domain: "com.fave.unknown", code: 1947, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("msg_something_wrong", comment: "")]))

            }
        }

        func handleVeritrans(paymentMethodsJSON: [[String: AnyObject]]) {

            let maybePrimaryMethodJSON: [String: AnyObject]? = paymentMethodsJSON.filter({ (item: [String : AnyObject]) -> Bool in
                return item["primary"] as! Bool
            }).first

            if let primaryMethodJSON = maybePrimaryMethodJSON {
                if let paymentMethod = PaymentMethod.serialize(primaryMethodJSON) {
                    viewModel.result.onNext(.PaymentMethods(data: [paymentMethod]))
                    viewModel.result.onCompleted()
                } else {
                    self.viewModel.result.onError(NSError(domain: "com.fave.unknown", code: 1947, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("msg_something_wrong", comment: "")]))

                }
                return
            } else {
                if let paymentMethod = PaymentMethod.serialize(paymentMethodsJSON[0]) {
                    viewModel.result.onNext(.PaymentMethods(data: [paymentMethod]))
                    viewModel.result.onCompleted()
                } else {
                    self.viewModel.result.onError(NSError(domain: "com.fave.unknown", code: 1947, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("msg_something_wrong", comment: "")]))

                }
            }
        }

        let jsonString = (message.body as! String).stringByRemovingPercentEncoding
        let json: [String: AnyObject] = try! NSJSONSerialization.JSONObjectWithData(jsonString!.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String : AnyObject]

        if message.name == "onAuthorizeCard" {
            // this could be 1 object if adyen and array if verytrans
            if let paymentMethodJSON = json["payment_method"] as? [String: AnyObject] {
                /// MARK: Adyen
                handleAdyen(paymentMethodJSON)
            } else {
                handleError(json)
            }
            return // keep every section (if case) 
        } else if message.name == "onAuthorizePayment" {
            guard let reservationJSON = json["reservation"] as? [String: AnyObject] else {
                return handleError(json)
            }

            if let reservation = Reservation.serialize(reservationJSON) {
                viewModel.result.onNext(.ReservationResponse(data: reservation))
                viewModel.result.onCompleted()
            } else {
                self.viewModel.result.onError(NSError(domain: "com.fave.unknown", code: 1947, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("msg_something_wrong", comment: "")]))

            }
            return // good habits die hard
        }

    }
}

extension Adyen3DSAuthenticationViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}

// MARK:- ViewModelBinldable
extension Adyen3DSAuthenticationViewController: ViewModelBindable {
    func bind() {
        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive
            }
            .subscribeNext { [weak self] (navigationClosure: NavigationClosure) in
                guard let strongSelf = self else { return }
                navigationClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)

        self.cancelBarButtonItem.rx_tap.subscribeNext { _ in
            self.viewModel.cancelButtonDidTap.onNext(())
        }.addDisposableTo(disposeBag)

        viewModel
            .webViewHTMLString
            .subscribeNext { (html: String) in
                self.webView.loadHTMLString(html, baseURL: NSURL(string: self.viewModel.adyenData.issuerURL)!)
        }.addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable
extension Adyen3DSAuthenticationViewController: Buildable {
    final class func build(builder: Adyen3DSAuthenticationViewControllerViewModel) -> Adyen3DSAuthenticationViewController {
        let storyboard = UIStoryboard(name: "Adyen3DSAuthentication", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! Adyen3DSAuthenticationViewController
        vc.viewModel = builder
        return vc
    }
}
