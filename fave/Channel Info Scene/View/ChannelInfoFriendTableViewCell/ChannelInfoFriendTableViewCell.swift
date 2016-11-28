//
//  ChannelInfoFriendTableViewCell.swift
//  fave
//
//  Created by Michael Cheah on 8/16/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelInfoFriendTableViewCell: TableViewCell {

    // MARK:- IBOutlet
    @IBOutlet weak var participantAvatarView: ParticipantAvatarView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var changeStatusButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    @IBAction func changeStatusButtonDidTap(sender: AnyObject) {
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "change_response", screenName: screenName.SCREEN_CONVERSATION_INFO)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

        let localyticsScreenEvent = LocalyticsEvent.createScreenEvent(screenName: screenName.SCREEN_CHAT_SELECT_RESPONSE)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsScreenEvent, providers: AnalyticsProviderType.Localytics)

        self.viewModel.changeStatus.onNext(())
    }

    // MARK:- ViewModel
    var viewModel: ChannelInfoFriendTableViewCellModel!

    override func updateConstraints() {
        bind()
        super.updateConstraints()
    }
}

// MARK:- ViewModelBinldable
extension ChannelInfoFriendTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.name.drive(friendNameLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.participantIsNotSelf.drive(changeStatusButton.rx_hidden).addDisposableTo(rx_reusableDisposeBag)
        viewModel.status.drive(statusLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)

        let avatar = viewModel.chatParticipant.value as Avatarable
        participantAvatarView.viewModel = ParticipantAvatarViewModel(avatar: Variable(avatar))

        participantAvatarView.croppedView.layer.cornerRadius = 20
        self.setNeedsDisplay()
    }
}
