//
//  ListingThingsToKnowTableViewCellViewModel.swift
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
 *  ListingThingsToKnowTableViewCellViewModel
 */
final class ListingThingsToKnowTableViewCellViewModel: ViewModel {

    // MARK:- Dependency

    // MARK:- State

    // MARK:- Input
    let listing: ListingType
    let cellHeight: Variable<CGFloat>

    // MARK:- Intermediate

    // MARK- Output
    let htmlText: String?

    init(listing: ListingType,
         cellHeight: Variable<CGFloat>) {
        self.listing = listing
        self.cellHeight = cellHeight
        htmlText = listing.finePrint
    }

    // MARK:- Life cycle
    deinit {

    }
}
