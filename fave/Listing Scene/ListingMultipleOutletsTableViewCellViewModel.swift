//
//  ActivityMultipleOutletsCellViewModel.swift
//  FAVE
//
//  Created by Syahmi Ismail on 17/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ActivityMultipleOutletsCellViewModel: ViewModel {

    // MARK:- Input
    let totalOutlet: Driver<String>
    // MARK:- Output

    // MARK:- Init
    init(numberOfOutlet: Int?) {
        if let totalRedeemableOutlet = numberOfOutlet where totalRedeemableOutlet > 1 {
            let remainRedeemableOutlet = totalRedeemableOutlet - 1
            if remainRedeemableOutlet > 1 {
                self.totalOutlet = Driver.of("\(NSLocalizedString("also_redeemable_in", comment: "")) \(remainRedeemableOutlet) \(NSLocalizedString("more_locations", comment: ""))")
            } else {
                self.totalOutlet = Driver.of("\(NSLocalizedString("also_redeemable_in", comment: "")) \(remainRedeemableOutlet) \(NSLocalizedString("more_location", comment: ""))")
            }
        } else {
            self.totalOutlet = Driver.of("")
        }
    }
}
