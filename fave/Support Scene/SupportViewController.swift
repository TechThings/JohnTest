//
//  SupportViewController.swift
//  FAVE
//
//  Created by Michael Cheah on 7/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ZendeskSDK
import ZDCChat

final class SupportViewController: ViewController {

    // MARK:- IBOutlet

    @IBOutlet weak var talkUsButton: UIButton!
    @IBOutlet weak var ticketButton: UIButton!
    @IBOutlet weak var faqButton: UIButton!
    // MARK:- ViewModel
    var viewModel: SupportViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
    }

    func setup() -> Void {

        self.title = NSLocalizedString("more_faq_title_text", comment: "")
        self.talkUsButton.setTitle(NSLocalizedString("faq_start_chat_text", comment: ""), forState: .Normal)
        self.ticketButton.setTitle(NSLocalizedString("faq_my_tickets_text", comment: ""), forState: .Normal)
        self.faqButton.setTitle(NSLocalizedString("faq_text", comment: ""), forState: .Normal)

    }
    @IBAction func viewFAQ(sender: AnyObject) {
        guard let navController = self.navigationController else {
            return
        }

        // Remove "Contact Us" on the right hand side
        // https://developer.zendesk.com/embeddables/docs/ios/tickets_and_kb
        ZDKHelpCenter.setNavBarConversationsUIType(ZDKNavBarConversationsUIType.None)
        let helpCenterContentModel = ZDKHelpCenterOverviewContentModel.defaultContent()
        ZDKHelpCenter.pushHelpCenterOverview(navController, withContentModel: helpCenterContentModel)
    }

    @IBAction func openMyTickets(sender: AnyObject) {
        guard let navController = self.navigationController else {
            return
        }

        ZDKRequests.pushRequestListWithNavigationController(navController)
    }

    @IBAction func openChat(sender: AnyObject) {
        guard let navController = self.navigationController else {
            return
        }

        ZDCChat.updateVisitor(viewModel.visitorInfo)
        ZDCChat.startChatIn(navController, withConfig: viewModel.chatConfig)
    }
}

// MARK:- ViewModelBinldable

extension SupportViewController: ViewModelBindable {
    func bind() {
        // Nothing to do
    }
}

// MARK:- Buildable

extension SupportViewController: Buildable {
    final class func build(builder: SupportViewModel) -> SupportViewController {
        let storyboard = UIStoryboard(name: "Support", bundle: nil)
        let paymentViewController = storyboard.instantiateViewControllerWithIdentifier(String(SupportViewController)) as! SupportViewController
        paymentViewController.viewModel = builder

        return paymentViewController
    }
}
