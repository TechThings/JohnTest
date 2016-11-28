//
//  HomeFaveInformationTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 9/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  HomeFaveInformationTableViewCellViewModel State
 */
struct HomeFaveInformationTableViewCellViewModelState {
    // MARK:- Constant
    init (
        ) {
    }
}

/**
 *  @author Thanh KFit
 *
 *  HomeFaveInformationTableViewCellViewModel
 */
final class HomeFaveInformationTableViewCellViewModel: ViewModel {

    // MARK:- State
    let state: Variable<HomeFaveInformationTableViewCellViewModelState>
    let version = Variable("")
    let stagingMode = Variable("")
    let userProvider: UserProviderDefault

    init(state: HomeFaveInformationTableViewCellViewModelState = HomeFaveInformationTableViewCellViewModelState()
        , userProvider: UserProviderDefault = userProviderDefault
        ) {
        self.state = Variable(state)
        self.userProvider = userProvider
        super.init()
        self.version.value = "Version \(app.appVersion) (\(app.buildNumber))"
        self.stagingMode.value = "End point: \(app.mode.name)"
    }

    func goToOnBoarding() {
        if !userProvider.currentUser.value.isGuest {
            app.logoutSignal.onNext(())
        }

        lightHouseService.navigate
            .onNext { (viewController) in
                if let viewController = viewController as? HomeViewController {
                    let vm = OnboardingViewModel()
                    let vc = OnboardingViewController.build(vm)
                    let nvc = RootNavigationController.build(RootNavigationViewModel())
                    nvc.setViewControllers([vc], animated: true)
                    viewController.view.window?.rootViewController = nvc
                }
        }

    }
}

// MARK:- Refreshable
extension HomeFaveInformationTableViewCellViewModel: Refreshable {
    func refresh() {
    }
}

// MARK:- Statful
extension HomeFaveInformationTableViewCellViewModel: Statful {}
