//
//  FilterIsOffTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 9/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  FilterIsOffTableViewCellViewModel
 */
final class FilterIsOffTableViewCellViewModel: ViewModel {
    let title: Driver<String>

    init(
        state: ListingsViewModelState
        ) {
        self.title = Driver.of(NSLocalizedString("filter_is_off", comment: ""))
        super.init()
    }
}
