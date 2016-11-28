//
//  AvatarViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/18/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  AvatarViewModel
 */
final class AvatarViewModel: ViewModel {

    // MARK- Output
    let profileImageURL: Driver<NSURL?>
    let initial: Driver<String>
    let initialHidden: Driver<Bool>

    init(
        initial: String?
        , profileImageURL: NSURL?
        ) {
        self.profileImageURL = Driver.of(profileImageURL)

        if let initial = initial {
            let firstChar = String(initial[initial.startIndex])
            self.initial = Driver.of(firstChar.uppercaseString)
        } else {
            self.initial = Driver.of("")
        }

        self.initialHidden = Driver.of(profileImageURL != nil || initial == nil)
        super.init()
    }
}
