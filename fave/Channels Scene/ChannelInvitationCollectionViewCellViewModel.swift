//
//  ChannelInvitationCollectionViewCellViewModel.swift
//  FAVE
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelInvitationCollectionViewCellViewModel: ViewModel {

    // MARK: Dependancy
    private let channelProvider: ChannelProvider
    private let userProvider: UserProvider
    let rxAnalytics: RxAnalytics

    // MARK: Input
    let channel: Variable<Channel>
    let maybeButtonDidTap = PublishSubject<Void>()
    let yesButtonDidTap = PublishSubject<Void>()
    let noButtonDidTap = PublishSubject<Void>()

    // MARK: Output
    let yesStatic = Driver.of(NSLocalizedString("yes", comment: ""))
    let noStatic = Driver.of(NSLocalizedString("msg_dialog_no", comment: ""))
    let maybeStatic = Driver.of(NSLocalizedString("msg_dialog_maybe", comment: ""))
    let interestedToJoinStatic = Driver.of(NSLocalizedString("chat_are_you_interested", comment: ""))
    let originalPrice: Driver<String>
    let finalPrice: Driver<String>
    let outletName: Driver<String>
    let partnerName: Driver<String>
    let invitationTitle: Driver<String>
    let listingName: Driver<String>

    init(
        channel: Variable<Channel>
        , channelProvider: ChannelProvider = channelProviderDefault
        , userProvider: UserProvider = userProviderDefault
        , rxAnalytics: RxAnalytics = rxAnalyticsDefault
        ) {
        self.channel = channel
        self.channelProvider = channelProvider
        self.userProvider = userProvider
        self.rxAnalytics = rxAnalytics

        if (channel.value.listing.purchaseDetails.savingsUserVisible != nil) {
            originalPrice = Driver.of(channel.value.listing.purchaseDetails.originalPriceUserVisible)
        } else {
            originalPrice = Driver.of("")
        }
        finalPrice = Driver.of(channel.value.listing.purchaseDetails.finalPriceUserVisible)
        outletName = Driver.of(channel.value.listing.outlet.name)
        partnerName = Driver.of(channel.value.listing.company.name)
        listingName = Driver.of(channel.value.listing.name)

        invitationTitle = Driver.of(self.channel.value.channelTitle(forUser: userProvider.currentUser.value))

        super.init()

        maybeButtonDidTap
            .subscribeNext { [weak self] _ in
                self?.update(channel.value, withUserParticipationStatus: UserParticipationStatus.Maybe)
            }
            .addDisposableTo(disposeBag)

        yesButtonDidTap
            .subscribeNext { [weak self] _ in
                self?.update(channel.value, withUserParticipationStatus: UserParticipationStatus.Going)
            }
            .addDisposableTo(disposeBag)

        noButtonDidTap
            .subscribeNext { [weak self] _ in
                self?.update(channel.value, withUserParticipationStatus: UserParticipationStatus.NotGoing)
            }
            .addDisposableTo(disposeBag)

    }

    func openChannel(channel: Channel) {
        let vc = ChatContainerViewController.build(ChatContainerViewControllerViewModel(chatContainerViewControllerViewModelFunctionality: .InitiateIndependently(channel: Variable(channel))))
        vc.hidesBottomBarWhenPushed = true

        lightHouseService.navigate.onNext { (viewController: UIViewController) in
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func update(channel: Channel, withUserParticipationStatus userParticipationStatus: UserParticipationStatus) {
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
            .subscribeNext { [weak self] (result: UpdateParticipationStatusAPIResponsePayload) in
                self?.openChannel(result.channel)
            }
            .addDisposableTo(disposeBag)
    }
}
