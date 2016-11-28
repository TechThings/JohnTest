//
//  ChannelInfoViewModel.swift
//  FAVE
//
//  Created by Michael Cheah on 8/12/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ChatInfoItemKind {
    //case Header
    case FriendsHeader
    case InviteFriend
    case Friend
    case Separator
    case LeaveChat
}

final class ChatInfoItem {
    let itemType: ChatInfoItemKind
    let item: AnyObject?

    init(itemType: ChatInfoItemKind, item: AnyObject?) {
        self.item = item
        self.itemType = itemType
    }
}

/**
 *  @author Michael Cheah
 *
 *  ChannelInfoViewModel
 */

final class ChannelInfoViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let channelProvider: ChannelProvider
    private let rxSendBird: RxSendBird
    let trackingScreen: TrackingScreen
    let rxAnalytics: RxAnalytics

    // MARK:- Variable

    //MARK:- Input
    let chatParticipants: Variable<[ChatParticipant]>
    let channel: Variable<Channel>
    let leaveChatDidTap = PublishSubject<()>()
    let refreshSignal = PublishSubject<()>()

    // MARK:- Intermediate

    // MARK- Output
    var chatInfoItem = [ChatInfoItem]()

    init(channel: Variable<Channel>
        , userProvider: UserProvider = userProviderDefault
        , channelProvider: ChannelProvider = channelProviderDefault
        , rxSendBird: RxSendBird = rxSendBirdDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , rxAnalytics: RxAnalytics = rxAnalyticsDefault) {

        self.chatParticipants = Variable(channel.value.chatParticipants)
        self.userProvider = userProvider
        self.channel = channel
        self.channelProvider = channelProvider
        self.rxSendBird = rxSendBird
        self.trackingScreen = trackingScreen
        self.rxAnalytics = rxAnalytics

        super.init()

        leaveChatDidTap
            .subscribeNext { [weak self] _ in
                guard let strongSelf = self else { return }
                let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "leave_chat", screenName: screenName.SCREEN_CONVERSATION_INFO)
                strongSelf.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

                strongSelf.leave(strongSelf.channel.value)
            }.addDisposableTo(disposeBag)

        chatParticipants
            .asObservable()
            .subscribeNext { [weak self] (chatParticipant: [ChatParticipant]) in
                self?.refresh()
            }
            .addDisposableTo(disposeBag)

        channel
            .asObservable()
            .map { (channel: Channel) -> [ChatParticipant] in
                return channel.chatParticipants
            }
            .bindTo(self.chatParticipants)
            .addDisposableTo(disposeBag)

        // A hach to update the participants when we add friends (that's why we need to represente each item and section with a model!)
//        self.channelProvider
//            .channels
//            .asObservable()
//            .map { [weak self] (channels: [Channel]) -> Channel? in
//                return channels.filter { (channel: Channel) -> Bool in channel == self?.channel }.first
//            }
//            .filterNil()
//            .subscribeNext { [weak self] (channel: Channel) in
//                self?.participants = channel.chatParticipants
//                self?.refresh()
//            }
//            .addDisposableTo(disposeBag)
    }

    func leave(channel: Channel) {
        let response = rxSendBird.endMessagingWithChannelUrl(channel.url.absoluteString!)
            .flatMap {
                _ in
                return self.channelProvider.leave(channel)
            }
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)

        response
            .doOnError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            .subscribeNext { [weak self] (leaveChannelAPIResponsePayload: LeaveChannelAPIResponsePayload) in
                self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    guard let maybeVC: UIViewController = { () -> UIViewController? in
                        var result: UIViewController? = nil
                        viewController.navigationController?.viewControllers.forEach { (viewController: UIViewController) in
                            if viewController.isKindOfClass(ChannelsViewController.self) {
                                result = viewController
                            }
                        }
                        return result
                        }() else { return }
                    viewController.navigationController?.popToViewController(maybeVC, animated: true)
                })
            }
            .addDisposableTo(disposeBag)
    }

    var chatTitle: String {
        if (chatParticipants.value.count < 2) {
            // If everybody else left the group
            return NSLocalizedString("channel_info_everyone_left", comment: "")
        }

        let concatenatedNames: String = {
            let currentUserId = userProvider.currentUser.value.id
            let participantsWitoutSelf = chatParticipants.value.filter { (chatParticipant: ChatParticipant) -> Bool in
                let userId: Int? = chatParticipant.id
                return userId != currentUserId
            }

            let participantsNames = participantsWitoutSelf.map { (chatParticipant: ChatParticipant) -> String in chatParticipant.firstName }
            let result = String.participantsString(fromNames: participantsNames)
            return result
        }()

        let intent = self.channel.value.listing.categoryType.capitalizingFirstLetter()
        let chatWith = NSLocalizedString("chat_with", comment: "")
        return "\(intent) \(chatWith) \(concatenatedNames)"
    }
}

// MARK:- Refreshable

extension ChannelInfoViewModel: Refreshable {
    func refresh() {
        var infoItems = [ChatInfoItem]()
        //infoItems.append(ChatInfoItem(itemType:.Header, item:nil))
        infoItems.append(ChatInfoItem(itemType:.Separator, item:nil))
        infoItems.append(ChatInfoItem(itemType:.FriendsHeader, item:nil))
        infoItems.append(ChatInfoItem(itemType:.InviteFriend, item:chatParticipants))
        for participant in chatParticipants.value {
            infoItems.append(ChatInfoItem(itemType:.Friend, item:participant))
        }

        infoItems.append(ChatInfoItem(itemType:.Separator, item:nil))
        infoItems.append(ChatInfoItem(itemType:.LeaveChat, item:nil))
        self.chatInfoItem = infoItems
        refreshSignal.onNext(())
    }
}
