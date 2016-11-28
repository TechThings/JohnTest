//
//  ListingWhatYouGetTableViewCellModel.swift
//  FAVE
//
//  Created by Syahmi Ismail on 15/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingWhatYouGetTableViewCellModel: ViewModel {

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
        htmlText = listing.whatYouGet
    }

    // MARK:- Life cycle
    deinit {

    }
}
