//
//  UserCreditsTableViewCellModel.swift
//  fave
//
//  Created by Michael Cheah on 7/16/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  UserCreditsTableViewCellModel
 */

final class UserCreditsTableViewCellModel: ViewModel {

    // MARK- Output
    let userCreditsAmount: String

    init(userCreditsAmount: String) {
        self.userCreditsAmount = userCreditsAmount
    }

    // MARK:- Life cycle
    deinit {

    }
}
