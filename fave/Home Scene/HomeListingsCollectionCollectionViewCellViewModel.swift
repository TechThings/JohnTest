//
//  HomeListingsCollectionCollectionViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/2/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeListingsCollectionCollectionViewCellViewModel: ViewModel {
    let name = Variable("")
    let collectionDescription = Variable("")
    let imageURL = Variable<NSURL?>(nil)
    let numberOfOffers: Driver<String>
    let offersImageHidden: Driver<Bool>

    init(item: ListingsCollection) {

        if item.numberOfOffers > 1 {
            numberOfOffers = Driver.of("\(item.numberOfOffers) \(NSLocalizedString("offers_available", comment: ""))")
            offersImageHidden = Driver.of(false)
        } else if item.numberOfOffers == 1 {
            numberOfOffers = Driver.of("\(item.numberOfOffers) \(NSLocalizedString("offers_available", comment: ""))")
            offersImageHidden = Driver.of(false)
        } else {
            numberOfOffers = Driver.of("")
            offersImageHidden = Driver.of(true)
        }

        super.init()

        name.value = item.name
        collectionDescription.value = item.description
        imageURL.value = item.image

    }
}
