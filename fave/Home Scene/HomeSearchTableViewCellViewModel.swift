//
//  HomeSearchTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeSearchTableViewCellViewModel: ViewModel {

    // MARK:- Dependency
    let userProvider: UserProvider

    let name: Driver<String>
    var isCurrentUserAguest = false

    init(userProvider: UserProvider = userProviderDefault) {

        self.userProvider = userProvider

        name = userProvider
            .currentUser
            .asDriver()
            .map {userProvider.currentUser.value.isGuest ? "Welcome to Fave!" : "Hi " + ($0.name ?? "there")}

        super.init()
    }
}
