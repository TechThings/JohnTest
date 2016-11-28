//
//  MultipleOutletsViewControllerViewModel.swift
//  FAVE
//
//  Created by Syahmi Ismail on 17/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MultipleOutletsViewControllerViewModel: ViewModel {

    // CC: Should change to listingID to support Deeplink in the future
    let listing: ListingType
    // MARK:- Dependency
    init(
        listing: ListingType
        ) {
        self.listing = listing
        super.init()
    }
}

// MARK:- Refreshable
extension MultipleOutletsViewControllerViewModel: Refreshable {
    func refresh() {
        //
    }
}
