//
//  NearbyViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

/**
 *  @author Thanh KFit
 *
 *  NearbyViewModel State
 */
struct NearbyViewModelState {
    // MARK:- Constant
    let selectedPage: Int
    init (
        selectedPage: Int = 0
        ) {
        self.selectedPage = selectedPage
    }
}

/**
 *  @author Thanh KFit
 *
 *  NearbyViewModel
 */
final class NearbyViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen
    let filterProvider: FilterProvider

    // MARK:- State
    let state: Variable<NearbyViewModelState>

    // MARK:- Input
    let location: Variable<CLLocation?>

    // MARK- Output
    let filters: Variable<[Category]?>

    let segments: Variable<[(title: String, controllerGenerator: UIViewController)]> = Variable([])

    init(
        state: NearbyViewModelState = NearbyViewModelState()
        , userProvider: UserProvider = userProviderDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , filterProvider: FilterProvider = filterProviderDefault
        , location: Variable<CLLocation?> = Variable<CLLocation?>(nil)
        ) {

        self.trackingScreen = trackingScreen
        self.state = Variable(state)
        self.filterProvider = filterProvider
        self.filters = filterProvider.headerFilter
        self.location = location

        let emptyNearbyViewControllerViewModel = EmptyNearbyViewControllerViewModel()
        let emptyNearbyViewController = EmptyNearbyViewController.build(emptyNearbyViewControllerViewModel)
        segments.value = [(title: "", controllerGenerator: emptyNearbyViewController)]

        super.init()

        self.filters
            .asObservable()
            .filterNil()
            .filterEmpty()
            .subscribeNext { [weak self] (filters) in
                if let strongSelf = self {
                    var segmentControllers = [(title: String, controllerGenerator: UIViewController)]()
                    for filter in filters {
                        let title = filter.name
                        let viewModel = ListingsViewModel(category: filter, functionality: Variable(ListingsViewModelFunctionality.Initiate()))
                        let controller = ListingsViewController.build(viewModel)
                        controller.passLocationObservable(strongSelf.location)
                        segmentControllers.append((title: title, controllerGenerator: controller))
                    }
                    self?.segments.value = segmentControllers
                }
            }.addDisposableTo(disposeBag)
    }

    func updateViewModel(withState state: NearbyViewModelState) {
        self.state.value = state
    }

    func pageIndexFromDeepLink(deepLink: String) -> Int? {
        if let mainCategories = filters.value {
            for index in 0...mainCategories.count - 1 {
                if mainCategories[index].compareWithDeepLink(deepLink) {
                    return index
                }
            }
        }
        return nil
    }
}

// MARK:- Statful
extension NearbyViewModel: Statful {}
