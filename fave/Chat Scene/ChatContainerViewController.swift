//
//  ChatContainerViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ChatContainerViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var chatOfferView: ChatOfferView!
    @IBOutlet weak var offerHeightConstraint: NSLayoutConstraint!

    // MARK:- ViewModel
    var viewModel: ChatContainerViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_CONVERSATION)
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func setup() {
        chatOfferView.viewModel = ChatOfferViewModel(listing: viewModel.channel.value.listing)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("chat_info", comment: ""), style: .Plain, target: self, action: #selector(self.goToChannelInfo))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.faveBlue()

        let descriptor = UIFontDescriptor(name: "CircularStd-Book", size: 16.0)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(descriptor: descriptor, size: 16.0)], forState: UIControlState.Normal)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    func goToChannelInfo() {
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "info", screenName:screenName.SCREEN_CONVERSATION)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)
        let vc = ChannelInfoViewController.build(ChannelInfoViewModel(channel: viewModel.channel))
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func keyboardWillShow(notification: NSNotification) {
        offerHeightConstraint.constant = 50
        chatOfferView.featuredImageWidthConstraint.constant = 35
        chatOfferView.partnerStackView.hidden = true
        chatOfferView.partnerStackView.alpha = 0
        chatOfferView.offerDetailsStackView.axis = UILayoutConstraintAxis.Horizontal
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        offerHeightConstraint.constant = 88
        chatOfferView.featuredImageWidthConstraint.constant = 70
        chatOfferView.partnerStackView.hidden = false
        chatOfferView.partnerStackView.alpha = 1
        chatOfferView.offerDetailsStackView.axis = UILayoutConstraintAxis.Vertical
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        print("ChatContainerViewController deinit")
    }

}

// MARK:- ViewModelBinldable
extension ChatContainerViewController: ViewModelBindable {
    func bind() {

        viewModel
            .lightHouseService
            .navigate
            .filter({[weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive})

            .subscribeNext { [weak self](navigationClosure: NavigationClosure) in
                guard let strongSelf = self else {return}
                navigationClosure(viewController: strongSelf)
        }.addDisposableTo(disposeBag)

        viewModel
            .chatTitle
            .driveNext { [weak self] (title: String) in
                self?.title = title
            }.addDisposableTo(disposeBag)

    }
}

extension ChatContainerViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! ChatViewController
        vc.viewModel = ChatViewControllerViewModel(channel: viewModel.channel)
        vc.containerViewController = self
    }
}

// MARK:- Buildable
extension ChatContainerViewController: Buildable {
    final class func build(builder: ChatContainerViewControllerViewModel) -> ChatContainerViewController {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.ChatContainerViewController) as! ChatContainerViewController
        vc.viewModel = builder
        return vc
    }
}
