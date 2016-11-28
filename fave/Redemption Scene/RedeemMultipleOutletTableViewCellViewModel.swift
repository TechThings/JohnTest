//
//  RedeemMultipleOutletTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/18/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  RedeemMultipleOutletTableViewCellViewModel
 */
final class RedeemMultipleOutletTableViewCellViewModel: ViewModel {

    // MARK:- Variable
    let outletName: Driver<String>
    let selectedImage = Variable<UIImage?>(UIImage(named: "ic_checkbox"))
    let outlet: Outlet

    init(
        outlet: Outlet,
        selected: Bool
        ) {
        self.outletName = Driver.of(outlet.name)
        self.outlet = outlet
        super.init()
        updateSelectedImage(selected)
    }

    func updateSelectedImage(selected: Bool) {
        if selected {
            self.selectedImage.value = UIImage(named: "ic_checkbox_selected")
        } else {
            self.selectedImage.value = UIImage(named: "ic_checkbox")
        }
    }

}
