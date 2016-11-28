//
//  CreateChannelFilterCollectionViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateChannelFilterCollectionViewModel: ViewModel {
    let name = Variable("")
    let iconURL = Variable<NSURL?>(nil)

    init(item: Category) {
        super.init()
        name.value = item.name
        iconURL.value = item.icon_outline
    }
}
