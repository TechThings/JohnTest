//
//  FilterSectionSingleTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 9/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct FilterSingleSelected {
    let queryType: FilterQueryType
    var data: FilterSectionData?

    init(queryType: FilterQueryType, data: FilterSectionData?) {
        self.queryType = queryType
        self.data = data
    }
}

/**
 *  @author Thanh KFit
 *
 *  FilterSectionSingleTableViewCellViewModel
 */
final class FilterSectionSingleTableViewCellViewModel: ViewModel {

    // MARK:- Output
    var selectedFilter: FilterSingleSelected? = nil
    let section = Variable<FilterSection?>(nil)

    init(
        section: FilterSection, selectedId: Int?
        ) {
        super.init()
        self.section.value = section
        if let selectedId = selectedId {
            if let filterData = (section.data as? [FilterSectionData])?.filter({ (data) -> Bool in
                return data.id == selectedId
            }).first {
                selectedFilter = FilterSingleSelected(queryType: section.queryType, data: filterData)
            }
        }
    }

    func updateSelectedFilter(atIndex index: Int) {
        if let section = section.value,
            let indexData = section.data[index] as? FilterSectionData {
            if let data = selectedFilter?.data where data.id == indexData.id {
                self.selectedFilter?.data = nil
            } else {
                self.selectedFilter = FilterSingleSelected(queryType: section.queryType, data: indexData)
            }
        }
    }
}
