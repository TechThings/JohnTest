//
//  FilterCategoryCollectionViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 9/21/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  FilterCategoryCollectionViewCellViewModel
 */
final class FilterCategoryCollectionViewCellViewModel: ViewModel {

    let name: Driver<String>
    let icon: Driver<NSURL?>
    let color = Variable<UIColor?>(UIColor(hexStringFast: "BBC5CC"))
    var selected: Bool
    let category: SubCategory

    init(category: SubCategory, isSelected: Bool) {
        self.name = Driver.of(category.name)
        self.icon = Driver.of(category.icon_url)
        self.selected = isSelected
        self.category = category
        super.init()
        if isSelected {
            color.value = category.color_hex
        }
    }

    func updateSelected() {
        selected = !selected
        if selected {
            color.value = category.color_hex
        } else {
            color.value = UIColor(hexStringFast: "BBC5CC")
        }
    }
}
