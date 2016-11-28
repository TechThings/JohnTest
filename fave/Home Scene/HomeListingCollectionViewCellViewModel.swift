//
//  HomeActivitesCellViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeListingCollectionViewCellViewModel: ViewModel {
    let listing: ListingType

    init(listing: ListingType) {
        self.listing = listing
    }
}
