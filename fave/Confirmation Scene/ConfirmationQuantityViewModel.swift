//
//  ConfirmationQuantityViewModel.swift
//  fave
//
//  Created by Michael Cheah on 7/8/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  ConfirmationQuantityViewModel
 */

final class ConfirmationQuantityViewModel: ViewModel {

    // MARK:- Input
    let currentSlot: Variable<Int>!
    let maxQuantity: Int

    let label: String

    init(currentSlot: Variable<Int>!,
         maxQuantity: Int) {
        self.label = NSLocalizedString("confirmation_quantity_text", comment: "")
        self.currentSlot = currentSlot
        self.maxQuantity = maxQuantity
    }

    // MARK:- Life cycle
    deinit {

    }
}
