//
//  GuestViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 15/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  GuestViewControllerViewModel
 */
final class GuestViewControllerViewModel: ViewModel {

    // MARK- Output
    let text: Driver<String>
    let continueButtonTitle: Driver<String>
    let isCurrentUserAguest = Variable(true)

    let userProvider: UserProviderDefault

    init(
        userProvider: UserProviderDefault = userProviderDefault
        ) {

        text = Driver.of(NSLocalizedString("guest_description_text", comment: ""))
        continueButtonTitle = Driver.of(NSLocalizedString("getting_started_continue_button_text", comment: ""))
        self.userProvider = userProvider
        super.init()
    }

    // MARK:- Life cycle
    deinit {

    }

}
