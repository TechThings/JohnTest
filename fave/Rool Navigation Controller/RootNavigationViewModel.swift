//
//  RootNavigationViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  RootNavigationViewModel
 */
class RootNavigationViewModel: ViewModel {
    let setAsRoot: Bool
    init(
        setAsRoot: Bool = false
        ) {
        self.setAsRoot = setAsRoot
    }

}
