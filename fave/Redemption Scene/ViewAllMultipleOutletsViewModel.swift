//
//  ViewAllMultipleOutletsViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ViewAllMultipleOutletsViewModel
 */
final class ViewAllMultipleOutletsViewModel: ViewModel {

    // MARK:- Input
    let listing: ListingType
    let viewAllLocationsDidTap = PublishSubject<Void>()

    init(listing: ListingType
        ) {
        self.listing = listing
        super.init()

        viewAllLocationsDidTap
            .subscribeNext { [weak self] _ in
                self?.viewAllLocations()
            }.addDisposableTo(disposeBag)
    }

    private func viewAllLocations() {
        let vc = MultipleOutletsViewController.build(MultipleOutletsViewControllerViewModel(listing: listing))
        let nvc = UINavigationController(rootViewController: vc)

        lightHouseService
            .navigate
            .onNext { (viewController) in
                viewController.presentViewController(nvc, animated: true, completion: nil)
        }
        /*
        let vc = MultipleOutletsViewController.build(MultipleOutletsViewControllerViewModel(listing: listing))
        lightHouseService.navigate
            .onNext { (viewController) in
                viewController.navigationController?.pushViewController(vc, animated: true)
        }
 */
    }

}
