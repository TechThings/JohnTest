//
//  ListingsGroupedAllOffersViewControllerViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  ListingsGroupedAllOffersViewControllerViewModel
 */
final class ListingsGroupedAllOffersViewControllerViewModel: ViewModel {

    let outlet: Outlet
    let title: Driver<String?>

    init(
        outlet: Outlet
        ) {
        self.outlet = outlet
        self.title = Driver.of(outlet.company?.name)
        super.init()
    }
}

// MARK:- Refreshable
extension ListingsGroupedAllOffersViewControllerViewModel: Refreshable {
    func refresh() {
    }
}
