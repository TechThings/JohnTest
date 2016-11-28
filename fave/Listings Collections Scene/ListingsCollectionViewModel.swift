//
//  ListingsCollectionViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingsCollectionViewModel: ViewModel {

    // MARK:- Dependency

    // MARK:- Input    
    let listingsCollection: ListingsCollection

    // MARK- Output
    let name: Driver<String>
    let collectionDescription: Driver<String>
    let imageURL: Driver<NSURL?>
    let offerCountText: Driver<String>

    init(
        listingsCollection: ListingsCollection
        ) {
        self.listingsCollection = listingsCollection
        name = Driver.of(listingsCollection.name)
        collectionDescription = Driver.of(listingsCollection.description)
        imageURL = Driver.of(listingsCollection.image)
        offerCountText = Driver.of("\(listingsCollection.numberOfOffers) \(NSLocalizedString("offers_available", comment: ""))")

        super.init()
    }
}
