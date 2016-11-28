//
//  EmptyNearbyViewControllerViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/24/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  EmptyNearbyViewControllerViewModel
 */
final class EmptyNearbyViewControllerViewModel: ViewModel {

    // MARK:- Dependency
    let filterProvider: FilterProvider
    let tryAgainButtonDidTap = PublishSubject<Void>()

    init(
        filterProvider: FilterProvider = filterProviderDefault
        ) {
        self.filterProvider = filterProvider
        super.init()

        tryAgainButtonDidTap
            .asObserver()
            .subscribeNext { [weak self] () in
                self?.filterProvider.refresh()
            }.addDisposableTo(disposeBag)
    }

}

// MARK:- Refreshable
extension EmptyNearbyViewControllerViewModel: Refreshable {
    func refresh() {
        filterProvider.refresh()
    }
}
