//
//  UserCreditsTableViewCell.swift
//  fave
//
//  Created by Michael Cheah on 7/16/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserCreditsTableViewCell: TableViewCell {

    @IBOutlet weak var creditAmountLabel: UILabel!

    // MARK:- ViewModel
    var viewModel: UserCreditsTableViewCellModel!

    // MARK:- Constant

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        // Nothing as of now
    }
}

// MARK:- ViewModelBinldable
extension UserCreditsTableViewCell: ViewModelBindable {
    func bind() {
        self.creditAmountLabel.text = String(format: "You have %@ in credits", viewModel.userCreditsAmount)
    }
}
