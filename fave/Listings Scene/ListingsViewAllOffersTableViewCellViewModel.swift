//
//  ListingsViewAllOffersTableViewCellViewModel.swift
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
 *  ListingsViewAllOffersTableViewCellViewModel
 */
final class ListingsViewAllOffersTableViewCellViewModel: ViewModel {

    let outlet: Outlet
    init(
        outlet: Outlet
        ) {
        self.outlet = outlet
        super.init()

    }
}
