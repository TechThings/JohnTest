//
//  ListingCollectionDetailTableViewCellViewModel.swift
//  FAVE
//
//  Created by Gautam on 22/08/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingCollectionDetailTableViewCellViewModel: ViewModel {

    // MARK:- Input
    private let collections: [ListingsCollection]

    // MARK:- Output
    let collectionName: Driver<String>

    // MARK:- Init
    init(collections: [ListingsCollection]) {
        self.collections = collections

        let collection = self.collections[0]

        self.collectionName = Driver.of(collection.name)

        super.init()

    }
}
