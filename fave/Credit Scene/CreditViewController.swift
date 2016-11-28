//
//  CreditViewController.swift
//  KFIT
//
//  Created by Nazih Shoura on 08/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import Social
import SwiftOverlays

final class CreditViewController: ViewController {

    // MARK: ViewModel
    var viewModel: CreditViewModel!

    // MARK: @IBOutlet Private
    @IBOutlet weak private var tableView: UITableView!

    // MARK: ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = NSLocalizedString("credit", comment: "")
        bind()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }

    func setupUI() {
        tableView.registerNib(UINib(nibName:String(CreditHeaderTableViewCell), bundle: nil), forCellReuseIdentifier: String(CreditHeaderTableViewCell))
        tableView.registerNib(UINib(nibName:String(CreditEarnMoreTableViewCell), bundle: nil), forCellReuseIdentifier: String(CreditEarnMoreTableViewCell))
        tableView.registerNib(UINib(nibName:String(CreditShareInviteTableViewCell), bundle: nil), forCellReuseIdentifier: String(CreditShareInviteTableViewCell))
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }
}

extension CreditViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.credit.value == nil ? 1 : 3
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 180
        }
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellViewModel = CreditHeaderTableViewCellViewModel(credit: viewModel.credit.value)
            let cell = tableView.dequeueReusableCellWithIdentifier(String(CreditHeaderTableViewCell), forIndexPath: indexPath) as! CreditHeaderTableViewCell
            cell.viewModel = cellViewModel
            cell.bind()
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(CreditEarnMoreTableViewCell), forIndexPath: indexPath) as! CreditEarnMoreTableViewCell
            cell.referralDescription = viewModel.credit.value?.referralDescription
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(CreditShareInviteTableViewCell), forIndexPath: indexPath) as! CreditShareInviteTableViewCell
            cell.codeLabel.text = viewModel.credit.value!.referralCode.uppercaseString
            cell.delegate = self
            return cell
        }
    }
}

extension CreditViewController: CreditShareInviteTableViewCellDelegate {

    func shareInviteCopyCode() {
        if let credit = viewModel.credit.value {
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = credit.referralCode
            self.showTextOverlay("\"\(credit.referralCode.uppercaseString)\" copied!")

            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.removeAllOverlays()
            }
        }
    }

    func shareInviteByWhatsapp() {
        guard let credit = viewModel.credit.value, var message = credit.shareMessages.whatsapp, let url = credit.shareMessages.url else {return}

        message += " " + url.absoluteString!

        let messageEncoding = message.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()).emptyOnNil

        let whatsappURL = NSURL(string: "whatsapp://send?text=\(messageEncoding)")
        if UIApplication.sharedApplication().canOpenURL(whatsappURL!) {
            UIApplication.sharedApplication().openURL(whatsappURL!)
        } else {
            viewModel.wireframeService.alertFor(title: NSLocalizedString("no_WhatsApp_available", comment: ""), message: NSLocalizedString("dont_have_WhatsApp_setup", comment: ""), preferredStyle: UIAlertControllerStyle.Alert, actions: nil)
        }
    }

    func shareInviteByTwitter() {
        guard let credit = viewModel.credit.value, var message = credit.shareMessages.message, let url = credit.shareMessages.url else {return}

        message += " " + url.absoluteString!

        let twitterApp = NSURL(string: "twitter://")

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let composer: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            composer.setInitialText(message)
            composer.addURL(url)
            self.presentViewController(composer, animated: true, completion: nil)
        } else if UIApplication.sharedApplication().canOpenURL(twitterApp!) {
            let messageEncoding = message.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()).emptyOnNil
            let twitterURL = NSURL(string: "twitter://post?message=\(messageEncoding)")
            if UIApplication.sharedApplication().canOpenURL(twitterURL!) {
                UIApplication.sharedApplication().openURL(twitterURL!)
            }
        } else {
            let messageEncoding = message.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()).emptyOnNil
            let twitterURL = NSURL(string: "http://twitter.com/share?text=\(messageEncoding)")
            if UIApplication.sharedApplication().canOpenURL(twitterURL!) {
                UIApplication.sharedApplication().openURL(twitterURL!)
            }
        }
    }

    func shareInviteByFacebook() {
        guard let credit = viewModel.credit.value, var message = credit.shareMessages.message, let url = credit.shareMessages.url else {return}

        message += " " + url.absoluteString!

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let composer: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            composer.setInitialText(message)
            composer.addURL(url)
            self.presentViewController(composer, animated: true, completion: nil)
        } else {
            viewModel.wireframeService.alertFor(title: NSLocalizedString("no_facebook_available", comment: ""), message: NSLocalizedString("dont_have_facebook_setup", comment: ""), preferredStyle: UIAlertControllerStyle.Alert, actions: nil)
        }
    }

    func shareInviteByEmail() {
        guard let credit = viewModel.credit.value, var message = credit.shareMessages.email, let url = credit.shareMessages.url else {return}
        message += " " + url.absoluteString!

        let subject = NSLocalizedString("Hey_workout_together", comment: "")
        let subjectEncoding = subject.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()).emptyOnNil
        let messageEncoding = message.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()).emptyOnNil

        let gmailURL = NSURL(string: "googlegmail:///co?subject=\(subjectEncoding)&body=\(messageEncoding)")

        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.setMessageBody(message, isHTML: false)
            composer.setSubject(subject)
            composer.mailComposeDelegate = self
            UIViewController.currentViewController?.presentViewController(composer, animated: true, completion: nil)
        } else if UIApplication.sharedApplication().canOpenURL(gmailURL!) {
            UIApplication.sharedApplication().openURL(gmailURL!)
        } else {
            viewModel.wireframeService.alertFor(title: NSLocalizedString("cannot_send_sms", comment: ""), message: NSLocalizedString("unavailable_to_send_sms", comment: ""), preferredStyle: UIAlertControllerStyle.Alert, actions: nil)
        }
    }

    func shareInviteBySMS() {
        guard let credit = viewModel.credit.value, var message = credit.shareMessages.message, let url = credit.shareMessages.url else {return}
        message += " " + url.absoluteString!

        if MFMessageComposeViewController.canSendText() {
            let composer = MFMessageComposeViewController()
            composer.body = message
            composer.messageComposeDelegate = self
            UIViewController.currentViewController?.presentViewController(composer, animated: true, completion: nil)
        } else {
            viewModel.wireframeService.alertFor(title: NSLocalizedString("cannot_send_sms", comment: ""), message: NSLocalizedString("unavailable_to_send_sms", comment: ""), preferredStyle: UIAlertControllerStyle.Alert, actions: nil)
        }
    }
}

extension CreditViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CreditViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CreditViewController: ViewModelBindable {
    func bind() {
        viewModel.credit.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext {
                [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

extension CreditViewController: Buildable {
    final class func build(builder: CreditViewModel) -> CreditViewController {
        let storyboard = UIStoryboard(name: "Credit", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(CreditViewController)) as! CreditViewController
        vc.viewModel = builder
        builder.refresh()
        return vc
    }
}

extension CreditViewController: DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) ->
        CreditViewController? {
            return build(CreditViewModel())
        }
}
