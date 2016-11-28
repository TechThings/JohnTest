//
//  HomeFiltersTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeFiltersTableViewCellViewModel: ViewModel {
    // MARK:- Dependency
    private let filterProvider: FilterProvider

    let filters = Variable([Category]())

    init(
        filterProvider: FilterProvider = filterProviderDefault
        ) {
        self.filterProvider = filterProvider
        super.init()

        filterProvider
            .headerFilter
            .asObservable()
            .filterNil()
            .bindTo(filters)
            .addDisposableTo(disposeBag)
    }

    func didSelectItemAtIndex(index: Int) {
        UIView.animateWithDuration(0.0, animations: {
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.nearby.rawValue
        }) { (_) in
            if let nearbyNVC = RootTabBarController.shareInstance?.viewControllers![RootTabBarControllerTab.nearby.rawValue] as? RootNavigationController {
                if let nearbyVC = nearbyNVC.topViewController as? NearbyViewController {
                    nearbyVC.setCurrentPage(index)
                }
            }
        }
    }

    final class func heightForFilterSection(numberOfCategories count: Int) -> CGFloat {
        if count == 0 {return 0}

        if count <= 3 {
            return layoutConstraint.homeCategoryTopSpacing + layoutConstraint.homeCategoryItemHeight + layoutConstraint.homeCategoryBottomSpacing
        }
        if count <= 6 {
            return layoutConstraint.homeCategoryTopSpacing + layoutConstraint.homeCategoryItemHeight * 2 + layoutConstraint.homeCategorySpacing + layoutConstraint.homeCategoryBottomSpacing
        }

        return 0
    }
}
