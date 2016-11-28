//
//  EmptyChannelsViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  EmptyChannelsViewControllerViewModel
 */
final class EmptyChannelsViewControllerViewModel: ViewModel {

    // MARK:- Dependency
    let userProvider: UserProvider
    let settingsProvider: SettingsProvider

    var showCashback: Driver<Bool> = Driver.of(true)

    //MARK:- Input
    let createChannelButtonDidTap = PublishSubject<()>()

    // MARK:- Intermediate

    // MARK- Output
    var isLoading: Driver<Bool> = Driver.of(true)
    var creditsText: Driver<String>

    init(
        userProvider: UserProvider = userProviderDefault
        , settingsProvider: SettingsProvider = settingsProviderDefault
        ) {
        self.userProvider = userProvider
        self.settingsProvider = settingsProvider
        let cashbackAmount = settingsProvider.settings.value.chatCreditPercentage

        self.creditsText = Driver.of(String(format: NSLocalizedString("chat_get_cachback_for_each_friend", comment: ""), String(cashbackAmount), String("%")) + " \(NSLocalizedString("learn_more", comment: ""))")

        super.init()

        showCashback = Driver.of(settingsProvider.settings.value.chatCreditFeature)

        isLoading = app.activityIndicator.asDriver()

        createChannelButtonDidTap
            .subscribeNext { [weak self] _ in
                let nvc = RootNavigationController.build(RootNavigationViewModel())
                if userProvider.currentUser.value.isGuest {
                    let vm = EnterPhoneNumberViewControllerViewModel(enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality.LoginAGuestUser)
                    let vc = EnterPhoneNumberViewController.build(vm)
                    nvc.setViewControllers([vc], animated: false)
                } else {
                    let vc = CreateChannelViewController.build(CreateChannelViewControllerViewModel())
                    nvc.setViewControllers([vc], animated: true)
                }

                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    viewController.presentViewController(nvc, animated: true, completion: nil)
                }

            }.addDisposableTo(disposeBag)
    }
}
