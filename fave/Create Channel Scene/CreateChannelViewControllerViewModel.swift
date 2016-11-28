//
//  CreateChannelViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SendBirdSDK

/**
 *  @author Nazih Shoura
 *
 *  CreateChannelViewControllerViewModel
 */
final class CreateChannelViewControllerViewModel: ViewModel {

    // MARK:- Dependency
    private let channelProvider: ChannelProvider
    private let rxSendBird: RxSendBird
    private let userProvider: UserProvider
    private let cityProvider: CityProvider

    let rxAnalytics: RxAnalytics
    let trackingScreen: TrackingScreen

    //MARK:- Input
    let createChannelButtonDidTap = PublishSubject<Void>()
    let selectParticipantsButtonDidTap = PublishSubject<Void>()
    let selectChannelListingButtonDidTap = PublishSubject<Void>()

    let chatParticipants: Variable<[ChatParticipant]>
    let channelListing: Variable<ListingType?>

    // MARK:- Intermediate
    private var createChannelAPIResponsePayload: Variable<CreateChannelAPIResponsePayload?> = Variable(nil)

    // MARK- Output Static
    let startNewChat: Driver<String> = Driver.of(NSLocalizedString("chat_do_more_together", comment: ""))
    let startNewChatDescription: Driver<String> = Driver.of(NSLocalizedString("chat_plan_to_go_with_friends", comment: ""))
    let letDoIt: Driver<String> = Driver.of(NSLocalizedString("let_do_it", comment: ""))

    // MARK- Output Dynamic
    let createdChannel: Variable<Channel?> = Variable(nil)
    let filters = Variable([Category]())
    let participants: Driver<String>
    let participantsColor: Driver<UIColor>
    let offerInfo: Driver<String>
    let offerInfoColor: Driver<UIColor>
    let createChannelButtonEnabled: Driver<Bool>

    init(
        channelProvider: ChannelProvider = channelProviderDefault
        , filterProvider: FilterProvider = filterProviderDefault
        , chatParticipants: Variable<[ChatParticipant]> = Variable([ChatParticipant]())
        , channelListing: Variable<ListingType?> = Variable(nil)
        , rxSendBird: RxSendBird = rxSendBirdDefault
        , userProvider: UserProvider = userProviderDefault
        , cityProvider: CityProvider = cityProviderDefault
        , rxAnalytics: RxAnalytics   = rxAnalyticsDefault
        , trackingScreen: TrackingScreen  = trackingScreenDefault
        ) {
        self.channelProvider = channelProvider
        self.chatParticipants = chatParticipants
        self.channelListing = channelListing
        self.rxSendBird = rxSendBird
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.rxAnalytics = rxAnalytics
        self.trackingScreen = trackingScreen

        participantsColor = chatParticipants
            .asDriver()
            .map({ (chatParticipant: [ChatParticipant]) -> UIColor in
                if chatParticipant.isEmpty { return UIColor(hexStringFast: "3ba9cf") } else { return UIColor.blackColor() }
            })

        participants = chatParticipants
            .asDriver()
            .map({ (chatParticipants: [ChatParticipant]) -> String in
                if chatParticipants.isEmpty {
                    return NSLocalizedString("choose_some_friend", comment: "")
                }

                var result = NSLocalizedString("chat_with", comment: "")
                let participantsNames = chatParticipants
                    .map { (chatParticipant: ChatParticipant) -> String in
                        chatParticipant.firstName
                }

                result = result
                    .stringByAppendingString(" ")
                    .stringByAppendingString(String.participantsString(fromNames: participantsNames))
                return result
            })

        offerInfoColor = channelListing
            .asDriver()
            .map { (listing: ListingType?) -> UIColor in
                if listing == nil { return UIColor(hexStringFast: "3ba9cf") } else { return UIColor.blackColor()
                }
        }

        offerInfo = channelListing
            .asDriver()
            .map { (listing: ListingType?) -> String in
                if let listing = listing {
                    return NSLocalizedString("at", comment:"")
                        .stringByAppendingString(" \(listing.company.name)")
                } else {
                    return NSLocalizedString("find_place_offer_to_go", comment: "")
                }
        }

        createChannelButtonEnabled = Observable
            .combineLatest(chatParticipants.asObservable()
            , channelListing.asObservable()) { (chatParticipants, channelListing) -> Bool in
                return chatParticipants.count > 0 && channelListing != nil
            }.asDriver(onErrorJustReturn: false)

        super.init()

        createChannelButtonDidTap
            .subscribeNext { [weak self] _ in
                self?.constructChannel()
            }.addDisposableTo(disposeBag)

        selectParticipantsButtonDidTap
            .subscribeNext { [weak self] _ in
                guard let strongSelf = self else { return }
                let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "select_friend", screenName: screenName.SCREEN_CHAT_NEW_CHAT)
                rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

                let vm = ContactsViewControllerViewModel(contactsViewControllerViewModelFunctionality: ContactsViewControllerViewModelFunctionality.InitiateChannel(chatParticipants: strongSelf.chatParticipants))
                let vc = ContactsViewController.build(vm)

                strongSelf
                    .lightHouseService
                    .navigate
                    .onNext({ (viewController) in
                        viewController.navigationController?.pushViewController(vc, animated: true)
                    })
            }
            .addDisposableTo(disposeBag)

        _ = filterProvider
            .headerFilter
            .asObservable()
            .filterNil()
            .filter { (filters) -> Bool in
                return filters.count > 0
            }
            .subscribeNext { [weak self] (filters: [Category]) in
                self?.filters.value = filters
            }
            .addDisposableTo(disposeBag)
    }

    func constructChannel() {
        let chatParticipants = self.chatParticipants.value
        guard let listing = channelListing.value else { return }
        guard let citySlug = cityProvider.currentCity.value?.slug else { return }

        var userIds = chatParticipants
            .filter { (chatParticipant: ChatParticipant) -> Bool in chatParticipant.id != nil }
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
                self?.trackChannelCreated(channel)
        }

        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "create_chat", screenName: screenName.SCREEN_CHAT_NEW_CHAT)
        rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)
    }

    func trackChannelCreated(channel: Channel) {
        let analyticsModel = ChatAnalyticsModel(channel: channel)
        analyticsModel.chatCreated.sendToMoEngage()
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

                strongSelf.createdChannel.value = createChannelAPIResponsePayload.channel

                let chatVC = ChatContainerViewController.build(ChatContainerViewControllerViewModel(chatContainerViewControllerViewModelFunctionality: .Initiate(channel: Variable(createChannelAPIResponsePayload.channel))))

                let setViewControllerClosure: SetViewControllerClosure = { (viewController: UIViewController) -> () in
                    let _ = viewController.presentingViewController

                    viewController.dismissViewControllerAnimated(true, completion: {

                        strongSelf
                        .lightHouseService
                        .navigate
                        .onNext({ (viewController) in
                            viewController.navigationController?.pushViewController(chatVC, animated: true)
                        })
                    })
                }

                strongSelf.lightHouseService.setViewControllerClosure.onNext(setViewControllerClosure)
            }
            .addDisposableTo(disposeBag)

    }
}
