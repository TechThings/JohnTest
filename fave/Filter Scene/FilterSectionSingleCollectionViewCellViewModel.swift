//
//  FilterSectionSingleCollectionViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 9/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  FilterSectionCollectionViewCellViewModel
 */
final class FilterSectionSingleCollectionViewCellViewModel: ViewModel {

    var isSelected: Bool
    let label: Driver<String?>
    let filterId: Int

    init(
        isSelected: Bool,
        data: FilterSectionData
        ) {
        self.filterId = data.id
        self.isSelected = isSelected
        self.label = Driver.of(data.name)
        super.init()

    }
}
