//
//  ChatContainerViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ChatContainerViewControllerViewModelFunctionality {
    case InitiateIndependently(channel: Variable<Channel>)
    case Initiate(channel: Variable<Channel>)
}

/**
 *  @author Nazih Shoura
 *
 *  ChatContainerViewControllerView_Model
 */
final class ChatContainerViewControllerViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let channelProvider: ChannelProvider
    let trackingScreen: TrackingScreen
    let rxAnalytics: RxAnalytics

    // MARK:- Variable

    //MARK:- Input
    let channel: Variable<Channel>

    // MARK:- Intermediate

    // MARK- Output
    let chatTitle: Driver<String>

    init(chatContainerViewControllerViewModelFunctionality: ChatContainerViewControllerViewModelFunctionality
        , userProvider: UserProvider = userProviderDefault
        , channelProvider: ChannelProvider = channelProviderDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , rxAnalytics: RxAnalytics  = rxAnalyticsDefault
        ) {
        self.userProvider = userProvider
        self.channelProvider = channelProvider
        self.trackingScreen = trackingScreen
        self.rxAnalytics = rxAnalytics

        var listenToChannelUpdate = false
        switch chatContainerViewControllerViewModelFunctionality {
        case .Initiate(let channel):
            self.channel = channel
        case .InitiateIndependently(let channel):
            self.channel = channel
            listenToChannelUpdate = true
        }

        self.chatTitle = Driver.of(self.channel.value.channelTitle(forUser: userProvider.currentUser.value))

        super.init()

        if (listenToChannelUpdate) {
            self.channelProvider.channels
                .asObservable()
                .map {
                    (newChannel: [Channel]) -> Channel? in
                    return newChannel.filter {
                        (aChannel: Channel) in
                        return aChannel.url == self.channel.value.url }.first
                }
                .filterNil()
                .bindTo(self.channel)
                .addDisposableTo(self.disposeBag)
        }
    }
}
