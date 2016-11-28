//
//  HomeListingsCollectionsTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeListingsCollectionsTableViewCellViewModel: ViewModel {
    let items = Variable([ListingsCollection]())

    init(collections: [ListingsCollection]) {
        super.init()
        items.value = collections
    }
}
