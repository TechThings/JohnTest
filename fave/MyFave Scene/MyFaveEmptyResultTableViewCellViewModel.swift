//
//  MyFaveEmptyResultTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  MyFaveEmptyResultTableViewCellViewModel
 */
final class MyFaveEmptyResultTableViewCellViewModel: ViewModel {

    let message: Driver<String>
    let details: Driver<String>
    init( message: String, details: String ) {
        self.message = Driver.of(message)
        self.details = Driver.of(details)
        super.init()
    }
}
