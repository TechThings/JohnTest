//
//  UserGenderViewModel.swift
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
 *  UserGenderViewModel
 */

final class UserGenderViewModel: ViewModel {

    // MARK- Output
    let details: String

    init(details: String) {
        self.details = details

    }

    // MARK:- Life cycle
    deinit {

    }
}
