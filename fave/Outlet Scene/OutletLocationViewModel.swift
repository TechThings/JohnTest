//
//  OutletLocationViewModel.swift
//  fave
//
//  Created by Michael Cheah on 7/13/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  OutletLocationViewModel
 */
final class OutletLocationViewModel: ViewModel {

    // MARK:- Dependency
    private let outlet: Outlet

    // MARK- Output
    let address: String

    init(outlet: Outlet) {
        self.outlet = outlet

        self.address = outlet.address!
    }

    // MARK:- Life cycle
    deinit {

    }
}
