//
//  ChannelInvitationsTableViewCellViewModel.swift
//  FAVE
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelInvitationsTableViewCellViewModel: ViewModel {
    let channels: Variable<[Channel]>
    let invitations: Driver<String>
    init(channels: [Channel]) {
        self.channels = Variable(channels)
        if channels.count == 1 {
            invitations = Driver.of(NSLocalizedString("chat_you_have_invitation", comment: ""))
        } else {
            let count = String(channels.count)
            invitations = Driver.of(String(format: NSLocalizedString("chat_invitations", comment: ""), count))
        }
        super.init()
    }
}
