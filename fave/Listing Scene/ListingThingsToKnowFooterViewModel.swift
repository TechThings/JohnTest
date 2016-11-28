//
//  ListingThingsToKnowFooterViewModel.swift
//  FAVE
//
//  Created by Syahmi Ismail on 26/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingThingsToKnowFooterViewModel: ViewModel {

    // MARK:- Input
    let didTapHowToRedeemButton = PublishSubject<()>()

    init() {

        super.init()

        didTapHowToRedeemButton
            .subscribeNext { [weak self] _ in
            let vc = HowToRedeemViewController.build(HowToRedeemViewControllerViewModel())
            let nvc = UINavigationController(rootViewController: vc)
            self?.lightHouseService.navigate.onNext { (viewController) in
                viewController.presentViewController(nvc, animated: true, completion: nil)
            }
        }
    }
}
