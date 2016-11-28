//
//  ReviewViewControllerViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  ReviewViewControllerViewModel
 */
final class ReviewViewControllerViewModel: ViewModel {

    // MARK- Input
    let companyId: Int

    init(
        companyId: Int
        , reviewsAPI: ReviewsAPI = ReviewsAPIDefault()
        ) {
        self.companyId = companyId
        super.init()
    }

}
