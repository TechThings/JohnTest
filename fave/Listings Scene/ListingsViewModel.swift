//
//  ListingsViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

enum ListingsViewModelFunctionality {
    case Initiate()
    case InitiateFromChat(channelListing: Variable<ListingType?> )
}

/**
 *  @author Thanh KFit
 *
 *  ListingsViewModel
 */
final class ListingsViewModel: ViewModel, HasFunctionality {
    let categoryType: String
    let category: Category
    let functionality: Variable<ListingsViewModelFunctionality>
    let location: Variable<CLLocation?> = Variable(nil)

    init(
         category: Category
        , functionality: Variable<ListingsViewModelFunctionality>
        ) {
        self.category = category
        self.functionality = functionality
        self.categoryType = category.type
        super.init()
    }
}

// MARK:- Refreshable
extension ListingsViewModel: Refreshable {
    func refresh() {
    }
}
