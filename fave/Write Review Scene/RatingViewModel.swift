//
//  RatingViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/16/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  RatingViewModel
 */
final class RatingViewModel: ViewModel {

    let rating = Variable<Float>(0)

    init(
        ) {
        super.init()

    }
}
