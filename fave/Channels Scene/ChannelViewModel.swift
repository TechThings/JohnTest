//
//  ChannelViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SendBirdSDK

/**
 *  @author Nazih Shoura
 *
 *  ChannelViewModel
 */
final class ChannelViewModel: ViewModel {

    // MARK:- Dependency
    private let rxSendBird: RxSendBird
    private let userProvider: UserProvider
    private let channelProvider: ChannelProvider
    let rxAnalytics: RxAnalytics

    // MARK:- Variable

    //MARK:- Input
    let channel: Variable<Channel>

    // MARK:- Intermediate
    let openChatButtonDidTap = PublishSubject<Void>()

    // MARK- Output
    let offerDescription: Driver<String>
    let timeStamp: Driver<String>
    let channelTitle: Driver<String>
    let unreadMessages: Driver<String>
    let unreadMessagesHidden: Driver<Bool>

    //MARK:- Signal
    let presentViewController = PublishSubject<UIViewController>()
    let pushViewController = PublishSubject<UIViewController>()
    let dismissViewController = PublishSubject<Void>()

    init(
        channel: Variable<Channel>
        , rxSendBird: RxSendBird = rxSendBirdDefault
        , userProvider: UserProvider = userProviderDefault
        , channelProvider: ChannelProvider = channelProviderDefault
        , rxAnalytics: RxAnalytics = rxAnalyticsDefault
        ) {
        self.channel = channel
        self.rxSendBird = rxSendBird
        self.userProvider = userProvider
        self.channelProvider = channelProvider
        self.rxAnalytics = rxAnalytics

        channelTitle = Driver.of(self.channel.value.channelTitle(forUser: userProvider.currentUser.value))

        offerDescription = Driver.of(channel.value.listing.company.name + ", " + channel.value.listing.outlet.name)

        let onMinuteTrigger = Observable<Int>.timer(0.0, period: 60.0, scheduler: ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))

        timeStamp = onMinuteTrigger
            .asDriver(onErrorJustReturn: 0)
            .map { _ -> String in
                guard let timeStamp = channel.value.messagingServiceChannel.value?.getLastMessageTimestamp() else { return "" }
                var timeAgoDate: NSDate
                if (timeStamp == 0) {
                    guard let createdTimeStamp = channel.value.messagingServiceChannel.value?.getCreatedAt() else { return "" }
                    timeAgoDate = NSDate(timeIntervalSince1970: NSTimeInterval(createdTimeStamp)) // OMG THEY RETURN SECONDS FOR THIS
                } else {
                    timeAgoDate = NSDate(timeIntervalSince1970: NSTimeInterval(timeStamp / 1000)) // OMG AND THEY RETURN MILLISECONDS HERE
                }
                return timeAgoDate.shortTimeAgoSinceNow()
        }

        let unreadMessagesInitial: String = {
            if let messagingServiceChannel = channel.value.messagingServiceChannel.value {
                let result = String(messagingServiceChannel.unreadMessageCount)
                return result
            }
            return ""
        }()

        unreadMessages = Driver.just(unreadMessagesInitial)

        let unreadMessagesHiddenInitial: Bool = {
            if let messagingServiceChannel = channel.value.messagingServiceChannel.value {
                let result = messagingServiceChannel.unreadMessageCount == 0
                return result
            }
            return true
        }()

        unreadMessagesHidden = Driver.just(unreadMessagesHiddenInitial)

        super.init()

        openChatButtonDidTap.subscribeNext { [weak self] _ in
            let vc = ChatContainerViewController.build(ChatContainerViewControllerViewModel(chatContainerViewControllerViewModelFunctionality: .Initiate(channel: channel)))
            vc.hidesBottomBarWhenPushed = true

            self?.lightHouseService
            .navigate
            .onNext({ (viewController) in
                viewController.navigationController?.pushViewController(vc, animated: true)
            })

            }.addDisposableTo(disposeBag)

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
            .addDisposableTo(disposeBag)
    }
}
