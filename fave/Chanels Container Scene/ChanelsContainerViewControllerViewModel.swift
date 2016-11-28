//
//  ChanelsContainerViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 17/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ChanelsContainerViewControllerViewModel State
 */
struct ChanelsContainerViewControllerViewModelState {
    // MARK:- Constant
    let <#Constant#>: <#Constant type#>

    init (
        ) {
    }
}

/**
 *  @author Nazih Shoura
 *
 *  ChanelsContainerViewControllerViewModel
 */
class ChanelsContainerViewControllerViewModel: ViewModel {

    // MARK:- State
    let state: Variable<ChanelsContainerViewControllerViewModelState>

    // MARK:- Dependency
    private let <#Dependency#>: <#Dependency type#>

    // MARK:- Variable
    private let <#Variable#>: Variable<<#Variable Type#>>

    //MARK:- Input
    let <#Button name#>ButtonDidTap = PublishSubject<Void>()

    // MARK:- Intermediate
    private let <#Intermediate#>: Observable<<#Intermediate Type#>>

    // MARK- Output
    let <#Output#>: Driver<<#Output Type#>>

    init(
        <#Dependency#>: <#Dependency type#> = <#Dependency type#>Default()
        , <#Variable#>: <#Variable Type#>
        , state: ChanelsContainerViewControllerViewModelState = ChanelsContainerViewControllerViewModelState()
        ) {
        self.<#Variable#> = Variable(<#Variable#>)
        self.state = Variable(state)
        self.<#Dependency#> = <#Dependency#>
        super.init()

    }

    // MARK:- Life cycle
    deinit {

    }
}

// MARK:- Refreshable
extension ChanelsContainerViewControllerViewModel: Refreshable {
    func refresh() {
        <#code#>
    }
}

// MARK:- Statful
extension ChanelsContainerViewControllerViewModel: Statful {}
