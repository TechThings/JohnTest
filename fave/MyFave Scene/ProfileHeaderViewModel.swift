//
//  ProfileHeaderViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  ProfileHeaderViewModel
 */
final class ProfileHeaderViewModel: ViewModel {
    // MARK- Output
    let avatarPhoto = Variable<NSURL?>(nil)
    let name = Variable("")
}
