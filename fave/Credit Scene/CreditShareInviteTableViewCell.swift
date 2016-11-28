//
//  CreditShareInviteTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CreditShareInviteTableViewCellDelegate : class {
    func shareInviteBySMS()
    func shareInviteByEmail()
    func shareInviteByTwitter()
    func shareInviteByFacebook()
    func shareInviteByWhatsapp()
    func shareInviteCopyCode()
}

final class CreditShareInviteTableViewCell: TableViewCell {

    @IBOutlet weak var codeLabel: UILabel!

    let analyticsModel = InviteAnalyticsModel()

    weak var delegate: CreditShareInviteTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func shareFacebookDidTap(sender: AnyObject) {
        if let delegate = delegate {
            delegate.shareInviteByFacebook()
            self.analyticsModel.inviteEvent(InvitePlatform.Fb).sendToMoEngage()
        }
    }

    @IBAction func shareTwitterDidTap(sender: AnyObject) {
        if let delegate = delegate {
            delegate.shareInviteByTwitter()
            self.analyticsModel.inviteEvent(InvitePlatform.Twitter).sendToMoEngage()
        }
    }

    @IBAction func shareSMSDidTap(sender: AnyObject) {
        if let delegate = delegate {
            delegate.shareInviteBySMS()
            self.analyticsModel.inviteEvent(InvitePlatform.Sms).sendToMoEngage()
        }
    }

    @IBAction func shareEmailDidTap(sender: AnyObject) {
        if let delegate = delegate {
            delegate.shareInviteByEmail()
            self.analyticsModel.inviteEvent(InvitePlatform.Email).sendToMoEngage()
        }
    }

    @IBAction func shareWhatsappDidTap(sender: AnyObject) {
        if let delegate = delegate {
            delegate.shareInviteByWhatsapp()
            self.analyticsModel.inviteEvent(InvitePlatform.WhatsApp).sendToMoEngage()
        }
    }

    @IBAction func shareLinkDidTap(sender: AnyObject) {
        if let delegate = delegate {
            delegate.shareInviteCopyCode()
            self.analyticsModel.inviteEvent(InvitePlatform.Code).sendToMoEngage()
        }
    }
}
