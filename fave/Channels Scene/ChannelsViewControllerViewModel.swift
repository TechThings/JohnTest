//
//  ChannelsViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ChannelsViewControllerViewModel
 */
final class ChannelsViewControllerViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let rxSendBird: RxSendBird
    let rxAnalytics: RxAnalytics

    // MARK:- Variable

    // MARK:- Input
    let createChannelButtonDidTap = PublishSubject<Void>()

    // MARK:- Intermediate

    // MARK- Output
    let emptyChannelsViewControllerContainerViewHidden: Driver<Bool>

    init(
        rxSendBird: RxSendBird = rxSendBirdDefault
        , userProvider: UserProvider = userProviderDefault
        , channelProvider: ChannelProvider = channelProviderDefault
        , rxAnalytics: RxAnalytics  = rxAnalyticsDefault
        ) {
        self.rxSendBird = rxSendBird
        self.userProvider = userProvider
        self.rxAnalytics = rxAnalytics
        self.emptyChannelsViewControllerContainerViewHidden = channelProvider.channels.asDriver()
            .map { (channels: [Channel]) -> Bool in !channels.isEmpty }

        super.init()

        createChannelButtonDidTap
            .throttle(0.2, scheduler: MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                let nvc = RootNavigationController.build(RootNavigationViewModel())
                let vc = CreateChannelViewController.build(CreateChannelViewControllerViewModel())
                nvc.setViewControllers([vc], animated: true)
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    viewController.presentViewController(nvc, animated: true, completion: nil)
                }

            }.addDisposableTo(disposeBag)
    }

    func updateActiveChannel() {
        if (userProvider.currentUser.value.isGuest == false) {
            self.rxSendBird.joinDefaultChannel()
        }
    }
}
