//
//  MyFaveViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum MyFavePage: Int {
    case Favourite = 0
    case Reservation
}

/**
 *  @author Thanh KFit
 *
 *  MyFaveViewModel State
 */
struct MyFaveViewModelState {
    // MARK:- Constant
    let selectedPage: MyFavePage
    init (
        selectedPage: MyFavePage = MyFavePage.Favourite
        ) {
        self.selectedPage = selectedPage
    }
}

/**
 *  @author Thanh KFit
 *
 *  MyFaveViewModel
 */
final class MyFaveViewModel: ViewModel {

    // MARK:- Dependency
    let userProvider: UserProvider

    // MARK:- State
    let state: Variable<MyFaveViewModelState>

    // MARK:- Input

    // MARK:- Intermediate

    // MARK- Output
    let user: Driver<User>
    let segments: [(title: String, controllerGenerator: (() -> UIViewController))]
    init(
        state: MyFaveViewModelState = MyFaveViewModelState()
        , userProvider: UserProvider = userProviderDefault
        , myFaveFaveOutletViewController: MyFaveFaveOutletViewController = MyFaveFaveOutletViewController.build(MyFaveFaveOutletViewModel())
        , myFaveCurrentReservationViewController: MyFaveCurrentReservationViewController = MyFaveCurrentReservationViewController.build(MyFaveCurrentReservationViewModel())
        ) {

        self.state = Variable(state)
        self.userProvider = userProvider

        user = userProvider
            .currentUser
            .asDriver()

        segments = [
            (title: NSLocalizedString("faves", comment: "")
                , controllerGenerator: { return myFaveFaveOutletViewController }
            )
            , (title: NSLocalizedString("my_fave_tab_title_2", comment: "")
                , controllerGenerator: { return myFaveCurrentReservationViewController })
                ]
        super.init()

    }

    func updateViewModel(withState state: MyFaveViewModelState) {
        self.state.value = state
    }
}

// MARK:- Statful
extension MyFaveViewModel: Statful {}
