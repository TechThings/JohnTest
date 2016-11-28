//
//  ChannelInfoFriendTableViewCellModel.swift
//  fave
//
//  Created by Michael Cheah on 8/16/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  ChallenInfoFriendTableViewCellModel
 */
final class ChannelInfoFriendTableViewCellModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let channelProvider: ChannelProvider
    let rxAnalytics: RxAnalytics

    // MARK:- Variable
    private var actionSheet: UIAlertController?

    // MARK:- Input
    let chatParticipant: Variable<ChatParticipant>
    private let channel: Variable<Channel>
    let changeStatus = PublishSubject<()>()

    // MARK:- Intermediate

    // MARK- Output
    var status: Driver<String> = Driver.of("")
    var name: Driver<String> = Driver.of("")
    var participantIsNotSelf: Driver<Bool> = Driver.of(true)

    init(channel: Variable<Channel>
        , chatParticipant: Variable<ChatParticipant>
        , userProvider: UserProvider = userProviderDefault
        , channelProvider: ChannelProvider = channelProviderDefault
        , rxAnalytics: RxAnalytics = rxAnalyticsDefault) {
        self.userProvider = userProvider
        self.channelProvider = channelProvider
        self.channel = channel
        self.chatParticipant = chatParticipant
        self.rxAnalytics = rxAnalytics

        super.init()

        self.status = self.chatParticipant.asDriver().map { (chatParticipant: ChatParticipant) -> String in
            return chatParticipant.participationStatusUserVisible
        }
        self.name = self.chatParticipant.asDriver().map { (chatParticipant: ChatParticipant) -> String in
            return chatParticipant.fullName
        }

        self.participantIsNotSelf = self.chatParticipant.asDriver().map { (chatParticipant: ChatParticipant) -> Bool in
            guard let participantId = chatParticipant.id else {
                return true
            }

            let userId = userProvider.currentUser.value.id
            return userId != participantId
        }

        changeStatus.subscribeNext { [weak self] _ in
            guard let strongSelf = self else {return}
            strongSelf.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                viewController.presentViewController(strongSelf.userParticipationStatusActionSheet, animated: true, completion: nil)
            }

            }.addDisposableTo(disposeBag)
    }

    var userParticipationStatusActionSheet: UIAlertController {
        if let actionSheet = self.actionSheet {
            return actionSheet
        }

        let actionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("change_status", comment: ""), message:nil, preferredStyle:UIAlertControllerStyle.ActionSheet)

        let goingAction = UIAlertAction(title:NSLocalizedString("display_status_going", comment: ""), style:UIAlertActionStyle.Default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            guard strongSelf.chatParticipant.value.participationStatus != UserParticipationStatus.Going else { return }

            let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "going", screenName: screenName.SCREEN_CHAT_SELECT_RESPONSE)
            self?.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

            strongSelf.updateChannel(channel: strongSelf.channel.value, withUserParticipationStatus: UserParticipationStatus.Going)})

        actionSheet.addAction(goingAction)

        let maybeAction = UIAlertAction(title:NSLocalizedString("display_status_may_be_going", comment: ""), style:UIAlertActionStyle.Default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            guard strongSelf.chatParticipant.value.participationStatus != UserParticipationStatus.Maybe else { return }

            let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "maybe", screenName: screenName.SCREEN_CHAT_SELECT_RESPONSE)
            self?.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

            strongSelf.updateChannel(channel: strongSelf.channel.value, withUserParticipationStatus: UserParticipationStatus.Maybe)})

        actionSheet.addAction(maybeAction)

        let notGoingAction = UIAlertAction(title:NSLocalizedString("display_status_not_going", comment: ""), style:UIAlertActionStyle.Default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            guard strongSelf.chatParticipant.value.participationStatus != UserParticipationStatus.NotGoing else { return }

            let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "not_going", screenName: screenName.SCREEN_CHAT_SELECT_RESPONSE)
            self?.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

            strongSelf.updateChannel(channel: strongSelf.channel.value, withUserParticipationStatus: UserParticipationStatus.NotGoing)})

        actionSheet.addAction(notGoingAction)

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
            (alertAction: UIAlertAction!) in
            actionSheet.dismissViewControllerAnimated(true, completion: nil)
        }))

        self.actionSheet = actionSheet

        return actionSheet
    }

    private func updateChannel(channel channel: Channel, withUserParticipationStatus userParticipationStatus: UserParticipationStatus) {
        let response = channelProvider.update(channel, withUserParticipationStatus: userParticipationStatus)
            .trackActivity(app.activityIndicator)
            .trackActivity(activityIndicator)

        response
            .doOnError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }

            }
            .subscribeNext({ [weak self] (updateParticipationStatusAPIResponsePayload: UpdateParticipationStatusAPIResponsePayload) in
                if let chatParticipant = updateParticipationStatusAPIResponsePayload.channel.chatParticipants.filter({ (chatParticipant: ChatParticipant) -> Bool in chatParticipant == self?.chatParticipant.value }).first {
                    self?.chatParticipant.value = chatParticipant
                }
            })
            .addDisposableTo(disposeBag)
    }

}
