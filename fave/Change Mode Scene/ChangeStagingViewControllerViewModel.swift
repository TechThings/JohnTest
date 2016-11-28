//
//  ChangeStagingViewControllerViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/29/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  ChangeStagingViewControllerViewModel
 */
final class ChangeStagingViewControllerViewModel: ViewModel {

    var current = Variable(0)

    init(
        ) {
        super.init()
        current.value = app.mode.rawValue
    }
}
