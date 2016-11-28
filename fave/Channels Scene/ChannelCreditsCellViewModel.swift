//
//  ChannelCreditsCellViewModel.swift
//  FAVE
//
//  Created by Gautam on 28/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Gautam
 *
 *  ChannelCreditsCellViewModel
 */
final class ChannelCreditsCellViewModel: ViewModel {

    //MARK:- Dependency
    private let settingsProvider: SettingsProvider

    //MARK:- Input
    let learnMoreButtonDidTap = PublishSubject<Void>()

    // MARK- Output
    let creditsText: Driver<String>

    init(settingsProvider: SettingsProvider = settingsProviderDefault) {
        self.settingsProvider = settingsProvider
        let cashbackAmount = settingsProvider.settings.value.chatCreditPercentage

        self.creditsText = Driver.of(String(format: NSLocalizedString("chat_get_cachback_for_each_friend", comment: ""), String(cashbackAmount), String("%")) + " \(NSLocalizedString("learn_more", comment: ""))")
        super.init()

        learnMoreButtonDidTap
            .subscribeNext { [weak self] _ in
                self?
                    .lightHouseService
                    .navigate
                    .onNext({ (viewController) in
                        let alertController = UIAlertController.alertController(forTitle: NSLocalizedString("terms", comment: "terms"), message: NSLocalizedString("chat_fave_credit_friends_redeemed_offer", comment: ""))

                        viewController.presentViewController(alertController, animated: true, completion: nil)
                    })
            }.addDisposableTo(disposeBag)

    }
}
