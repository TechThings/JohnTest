//
//  MyFaveContentViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/5/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum MyFaveType {
    case MyFaveTypeOutlet
    case MyFaveTypeReservation
}

final class MyFaveContentViewModel: ViewModel {

    // MARK:- Input
    let items = Variable([AnyObject]())
    let type: MyFaveType
    let outletSearchDelegate: OutletsSearchTableViewCellModelDelegate?

    init(type: MyFaveType, items: [AnyObject],
         outletSearchDelegate: OutletsSearchTableViewCellModelDelegate?) {
        self.type = type
        self.items.value = items
        self.outletSearchDelegate = outletSearchDelegate
        super.init()
    }
}
