//
//  ListingReviewTableViewCellViewModel.swift
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
 *  ListingReviewTableViewCellViewModel
 */
final class ListingReviewTableViewCellViewModel: ViewModel {

    // MARK- Output
    let avatar: Driver<String>
    let name: Driver<String>
    let comment: Driver<String>
    let rating: Driver<String>

    init(
        review: Review
        ) {
        avatar = Driver.of((review.name as NSString).substringToIndex(1))
        name = Driver.of(review.name)
        comment = Driver.of(review.comment)
        rating = Driver.of(String(review.rating))
        super.init()

    }
}
