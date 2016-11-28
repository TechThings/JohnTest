//
//  ChannelInfoInviteFriendsTableViewCellModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 22/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ChannelInfoInviteFriendsTableViewCellModel
 */
final class ChannelInfoInviteFriendsTableViewCellModel: ViewModel {

    // MARK:- Dependency

    // MARK:- Variable

    //MARK:- Input
    let addFriendsButtonDidTap = PublishSubject<Void>()
    let channel: Variable<Channel>
    let chatParticipants: Variable<[ChatParticipant]>

    // MARK- Output
    init(
        channel: Variable<Channel>
        , chatParticipants: Variable<[ChatParticipant]>
        ) {
        self.channel = channel
        self.chatParticipants = chatParticipants
        super.init()

        addFriendsButtonDidTap.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }
            let vm = ContactsViewControllerViewModel(contactsViewControllerViewModelFunctionality: ContactsViewControllerViewModelFunctionality.AddChannelParticipants(chatParticipants: chatParticipants, channel: channel))
            let vc = ContactsViewController.build(vm)
            strongSelf.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                viewController.navigationController?.pushViewController(vc, animated: true)
            })
        }.addDisposableTo(disposeBag)
    }
}
