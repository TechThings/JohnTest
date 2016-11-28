//
//  ChatTitleViewModel.swift
//  FAVE
//
//  Created by Michael Cheah on 8/23/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  ChatTitleViewModel
 */
final class ChatTitleViewModel: ViewModel {

    // MARK:- Dependency
    private let channel: Channel
    private let userProvider: UserProvider

    // MARK:- Variable

    //MARK:- Input

    // MARK:- Intermediate

    // MARK- Output
    let chatTitle: Driver<String>

    init(channel: Channel,
         userProvider: UserProvider = userProviderDefault) {
        self.channel = channel
        self.userProvider = userProvider
        chatTitle = Driver.of(self.channel.channelTitle(forUser: userProvider.currentUser.value))
        super.init()
    }

    // MARK:- Life cycle
    deinit {

    }
}
