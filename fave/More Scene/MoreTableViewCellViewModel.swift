//
//  MoreTableViewCellViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  MoreTableViewCellViewModel
 */
final class MoreTableViewCellViewModel: ViewModel {

    // MARK:- Dependency

    // MARK:- Input/output
    let iconImage: UIImage
    let detail: String
    let title: String
    let viewControllerPresentingStyleGenerator: () -> (ViewControllerPresentingStyle)

    // MARK:- Intermediate

    // MARK- Output

    init(
        iconImage: UIImage
        , title: String
        , detail: String
        , viewControllerPresentingStyleGenerator: () -> (ViewControllerPresentingStyle)
        ) {
        self.iconImage = iconImage
        self.detail = detail
        self.title = title
        self.viewControllerPresentingStyleGenerator = viewControllerPresentingStyleGenerator
    }

    // MARK:- Life cycle
    deinit {

    }
}
