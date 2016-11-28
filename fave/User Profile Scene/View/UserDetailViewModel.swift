//
//  UserDetailViewModel.swift
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
 *  UserDetailViewModel
 */

final class UserDetailViewModel: ViewModel {

    // MARK- Output
    let title: String
    let details: String

    init(title: String, details: String) {
        self.title = title
        self.details = details

    }

    // MARK:- Life cycle
    deinit {

    }
}
