//
//  ListingsCollectionHeaderViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 16/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ListingsCollectionHeaderViewModel
 */
final class ListingsCollectionHeaderViewModel: ViewModel {

    // MARK:- Input
    let listingsCollection: ListingsCollection

    // MARK- Output
    let imageURL: Driver<NSURL>
    let collectionDescription: Driver<String>
    let name: Driver<String>

    init(
        listingsCollection: ListingsCollection
        ) {
        self.listingsCollection = listingsCollection

        imageURL = Driver.of(listingsCollection.image)
        collectionDescription = Driver.of(listingsCollection.description)
        name = Driver.of(listingsCollection.name)

        super.init()

    }
}
