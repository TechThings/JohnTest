//
//  FilterViewControllerViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 9/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  FilterViewControllerViewModel
 */
final class FilterViewControllerViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- State
    var state: ListingsViewModelState

    // MARK:- Output
    let sections: Variable<[FilterSection]>
    let title: Driver<String>

    init(state: ListingsViewModelState,
         trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.state = state
        self.sections = Variable(state.category.filters)
        self.title = Driver.of("\(state.category.name) Filter")

        super.init()
    }

    // MARK:- Life cycle
    deinit {

    }

    func resetFilter() {
        state = ListingsViewModelState(page: 1,
                                     loadedEverything: false,
                                     subCategories: [SubCategory](),
                                     categoryType: state.categoryType,
                                     order: state.order,
                                     priceRanges: nil,
                                     distances: nil,
                                     category: state.category)
    }

    func updateSingleSelected(singleFilter: FilterSingleSelected?) {
        if let singleFilter = singleFilter {

            var filterId: Int?
            if let _ = singleFilter.data {
                filterId = singleFilter.data?.id
            }
            filterId = nil

            if singleFilter.queryType == FilterQueryType.Distances {
                state = ListingsViewModelState(page: 1,
                                             loadedEverything: false,
                                             subCategories: state.subCategories,
                                             categoryType: state.categoryType,
                                             order: state.order,
                                             priceRanges: state.priceRanges,
                                             distances: filterId,
                                             category: state.category)

            } else if singleFilter.queryType == FilterQueryType.PriceRanges {
                state = ListingsViewModelState(page: 1,
                                             loadedEverything: false,
                                             subCategories: state.subCategories,
                                             categoryType: state.categoryType,
                                             order: state.order,
                                             priceRanges: filterId,
                                             distances: state.distances,
                                             category: state.category)
            }
        }
    }

    func updateCategoriesSelected(categories: [SubCategory]) {
        state = ListingsViewModelState(page: 1,
                                     loadedEverything: false,
                                     subCategories: categories,
                                     categoryType: state.categoryType,
                                     order: state.order,
                                     priceRanges: state.priceRanges,
                                     distances: state.distances,
                                     category: state.category)
    }

}

// MARK:- Refreshable
extension FilterViewControllerViewModel: Refreshable {
    func refresh() {

    }
}
