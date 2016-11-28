//
//  FilterCategoriesCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/25/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class FilterCategoriesCellViewModel: ViewModel {
    var categories: [SubCategory]
    var selectedCategories = [SubCategory]()
    var countLabelHidden: Bool
    var countLabelText: String
    var guideLabelHidden: Bool
    var resetButtonHidden: Bool

    init(categories: [SubCategory], selectedCategories: [SubCategory]) {
        self.categories = categories
        self.selectedCategories = selectedCategories
        self.countLabelHidden = selectedCategories.count == 0
        self.countLabelText = selectedCategories.count > 1 ? "\(selectedCategories.count) categories selected" : "1 category selected"
        self.resetButtonHidden = selectedCategories.count == 0
        self.guideLabelHidden = selectedCategories.count > 0
        super.init()
    }

    func didSeletectCategory(category: SubCategory) {
        let selectedCategoriesIds = selectedCategories.map { (category) -> Int in
            return category.id
        }

        if let index = selectedCategoriesIds.indexOf(category.id) {
            selectedCategories.removeAtIndex(index)
        } else {
            selectedCategories.append(category)
        }
    }
}
