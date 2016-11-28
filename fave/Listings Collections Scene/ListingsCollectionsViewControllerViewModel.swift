//
//  ListingsCollectionsViewControllerViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 9/9/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  ListingsCollectionsViewControllerViewModel State
 */
struct ListingsCollectionsViewControllerViewModelState {
    // MARK:- Constant

    init (
        ) {
    }
}

/**
 *  @author Thanh KFit
 *
 *  ListingsCollectionsViewControllerViewModel
 */
final class ListingsCollectionsViewControllerViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- State
    let state: Variable<ListingsCollectionsViewControllerViewModelState>

    init(
        state: ListingsCollectionsViewControllerViewModelState = ListingsCollectionsViewControllerViewModelState()
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.state = Variable(state)
        super.init()

    }

    // MARK:- Life cycle
    deinit {

    }
}

// MARK:- Refreshable
extension ListingsCollectionsViewControllerViewModel: Refreshable {
    func refresh() {
        //
    }
}

// MARK:- Statful
extension ListingsCollectionsViewControllerViewModel: Statful {}
