//
//  ListingsHeaderTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import RxSwift
import RxCocoa

final class ListingsHeaderTableViewCellViewModel: ViewModel {
    let backgroundImage: NSURL
    let title: String
    let categoryDescription: String

    init(filter: Category) {
        backgroundImage = filter.background
        title = filter.name
        categoryDescription = filter.description
        super.init()
    }
}
