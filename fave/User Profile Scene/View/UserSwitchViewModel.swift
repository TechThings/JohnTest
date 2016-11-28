//
//  UserSwitchViewModel.swift
//  fave
//
//  Created by Michael Cheah on 7/14/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  UserSwitchViewModel
 */

final class UserSwitchViewModel: ViewModel {

    // MARK- Output
    let title: String
    let value: Bool

    init(title: String, value: Bool) {
        self.title = title
        self.value = value
    }

    // MARK:- Life cycle
    deinit {

    }
}
