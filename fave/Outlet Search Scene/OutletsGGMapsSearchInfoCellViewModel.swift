//
//  OutletsGGMapsSearchInfoCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 6/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class OutletsGGMapsSearchInfoCellViewModel: ViewModel {
    let message = Variable("")

    init(mess: String) {
        super.init()
        message.value = mess
    }
}
