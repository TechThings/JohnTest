//
//  ContactsViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 09/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SendBirdSDK

enum ContactsViewControllerViewModelFunctionality: Functionality {
    case AddChannelParticipants(chatParticipants: Variable<[ChatParticipant]>, channel: Variable<Channel>)
    case InitiateChat(chatParticipants: Variable<[ChatParticipant]>, listing: Variable<ListingType>)
    case InitiateChannel(chatParticipants: Variable<[ChatParticipant]>)
}

/**
 *  @author Nazih Shoura
 *
 *  ContactsViewControllerViewModel
 */
final class ContactsViewControllerViewModel: ViewModel, HasFunctionality {

    // MARK:- Dependency
    let cityProvider: CityProvider
    let channelProvider: ChannelProvider
    let userProvider: UserProvider
    let rxSendBird: RxSendBird
    let trackingScreen: TrackingScreen

    // MARK:- Variable

    // MARK:- Input
    let chatParticipants: Variable<[ChatParticipant]>
    let chatParticipantsBeingConstucted: Variable<[ChatParticipant]>
    let doneButtonDidTap = PublishSubject<()>()

    // MARK:- Intermediate

    // MARK- Output
    let doneButtonSettings: Driver<(Bool, String)>
    let functionality: Variable<ContactsViewControllerViewModelFunctionality>

    init(
        contactsViewControllerViewModelFunctionality: ContactsViewControllerViewModelFunctionality
        , channelProvider: ChannelProvider = channelProviderDefault
        , cityProvider: CityProvider = cityProviderDefault
        , userProvider: UserProvider = userProviderDefault
        , rxSendBird: RxSendBird = rxSendBirdDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.functionality = Variable(contactsViewControllerViewModelFunctionality)
        self.rxSendBird = rxSendBird
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.channelProvider = channelProvider
        self.trackingScreen = trackingScreen

        switch contactsViewControllerViewModelFunctionality {
        case .AddChannelParticipants(chatParticipants: let chatParticipants, channel: _):
            self.chatParticipants = chatParticipants
            self.chatParticipantsBeingConstucted = Variable(chatParticipants.value)
        case .InitiateChat(chatParticipants: let chatParticipants, listing: _):
            self.chatParticipants = chatParticipants
            self.chatParticipantsBeingConstucted = Variable(chatParticipants.value)
        case .InitiateChannel(chatParticipants: let chatParticipants):
            self.chatParticipants = chatParticipants
            self.chatParticipantsBeingConstucted = Variable(chatParticipants.value)
        }

        self.doneButtonSettings = chatParticipantsBeingConstucted
            .asDriver()
            .map({ (chatParticipantsBeingConstucted: [ChatParticipant]) -> (Bool, String) in
                switch contactsViewControllerViewModelFunctionality {
                case let .AddChannelParticipants(chatParticipants, _):
                    let filteredChatParticipant = chatParticipantsBeingConstucted.filter { (chatParticipantBeingConstucted: ChatParticipant) -> Bool in
                        !chatParticipants.value.contains(chatParticipantBeingConstucted) }
                    return (!filteredChatParticipant.isEmpty, "ADD (\(filteredChatParticipant.count))")
                case .InitiateChat: fallthrough
                case .InitiateChannel:
                    return (!chatParticipantsBeingConstucted.isEmpty, "CONTINUE (\(chatParticipantsBeingConstucted.count))")
                }

            })

        super.init()

        doneButtonDidTap.subscribeNext { [weak self] _ in
            guard let strongSelf = self else {return}
            switch contactsViewControllerViewModelFunctionality {
            case .InitiateChannel(_):
                // Submit the update
                strongSelf.chatParticipants.value = strongSelf.chatParticipantsBeingConstucted.value
                strongSelf.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.navigationController?.popViewControllerAnimated(true)
                })
            case .InitiateChat(chatParticipants: _, listing: let listing):
                self?.constructChannel(withListing: listing.value, chatParticipants: strongSelf.chatParticipantsBeingConstucted.value)
            case .AddChannelParticipants(chatParticipants: _, channel: let channel):
                self?.update(channel.value, withChannelchatParticipants: strongSelf.chatParticipantsBeingConstucted.value)
            }
            }
            .addDisposableTo(disposeBag)

    }

    func constructChannel(withListing listing: ListingType, chatParticipants: [ChatParticipant]) {
        guard let citySlug = cityProvider.currentCity.value?.slug else { return }

        var userIds = chatParticipants
            .filter { (chatParticipant: ChatParticipant) -> Bool in return chatParticipant.id != nil }
            .map { (chatParticipant: ChatParticipant) -> String in "\(chatParticipant.id!)" }

        userIds.append("\(userProvider.currentUser.value.id)")

        _ = rxSendBird.startMessaging(userIds)
            .map { (sendBirdMessagingChannel: SendBirdMessagingChannel) -> Channel in
                let channelURL = NSURL(string: sendBirdMessagingChannel.channel.url)!
                let channel = Channel(ownerId: self.userProvider.currentUser.value.id , url: channelURL, listing: listing, citySlug: citySlug, chatParticipants: chatParticipants)
                return channel
            }
            .trackActivity(app.activityIndicator)
            .subscribeNext { [weak self] (channel: Channel) in
                self?.create(channel)
        }
    }

    func update(channel: Channel, withChannelchatParticipants chatParticipants: [ChatParticipant]) {
        let newUserIds = chatParticipants
            .map { (chatParticipant: ChatParticipant) -> Int? in
                return chatParticipant.id
            }.filter { (id: Int?) -> Bool in
                return id != nil
            }.map { (id: Int?) -> String in
                return String(id!)
            }.unique()

        channel.chatParticipants = chatParticipants.unique()

        let response =
            rxSendBird.inviteMessagingWithChannelUrl(channel.url.absoluteString!, userIds: Array(newUserIds))
                .flatMap {
                    _ in
                    return self.channelProvider.post(channel)
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
            .subscribeNext { [weak self] (createChannelAPIResponsePayload: CreateChannelAPIResponsePayload) in
                // Submit the update
                guard let strongSelf = self else { return }
                strongSelf.chatParticipants.value = strongSelf.chatParticipantsBeingConstucted.value
                strongSelf.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.navigationController?.popViewControllerAnimated(true)
                })
            }
            .addDisposableTo(disposeBag)
    }

    func create(channel: Channel) {
        let response = channelProvider
            .post(channel)
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)

        response
            .doOnError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            .subscribeNext { [weak self] (createChannelAPIResponsePayload: CreateChannelAPIResponsePayload) in
                guard let strongSelf = self else {return}
                // Submit the update
                strongSelf.chatParticipants.value = strongSelf.chatParticipantsBeingConstucted.value

                let vc = ChatContainerViewController.build(ChatContainerViewControllerViewModel(chatContainerViewControllerViewModelFunctionality: .InitiateIndependently(channel: Variable(createChannelAPIResponsePayload.channel))))
                self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    guard let navigationController = viewController.navigationController else { return }
                    var viewControllers = navigationController.viewControllers
                    viewControllers.removeLast()
                    viewControllers.append(vc)
                    navigationController.setViewControllers(viewControllers, animated: true)
                })
            }
            .addDisposableTo(disposeBag)
    }
}
