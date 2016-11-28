//
//  CreditHeaderTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class CreditHeaderTableViewCellViewModel: ViewModel {
    var withCreditViewHidden: Bool = true
    var noCreaditViewHidden: Bool = false
    var creditText: String = ""

    init(credit: UserCredits?) {
        if let credit = credit {
            withCreditViewHidden = credit.creditCents <= 0
            noCreaditViewHidden = credit.creditCents > 0
            creditText = credit.credits
        }
    }

}
