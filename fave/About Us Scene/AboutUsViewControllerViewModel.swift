//
//  AboutUsViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  AboutViewControllerViewModel
 */
final class AboutUsViewControllerViewModel: ViewModel {

    // MARK:- Dependency
    let assetProvider: AssetProvider
    // MARK:- Input

    // MARK:- Intermediate
    let logoImage: Driver<UIImage?>

    // MARK- Output
    init(assetProvider: AssetProvider = assetProviderDefault) {
        self.assetProvider = assetProvider
        self.logoImage = assetProvider.imageAssest.asDriver().map { $0.aboutImage}
        super.init()
    }

    // MARK:- Life cycle
    deinit {

    }
}
