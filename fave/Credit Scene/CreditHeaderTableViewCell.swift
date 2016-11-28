//
//  CreditHeaderTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreditHeaderTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: CreditHeaderTableViewCellViewModel!

    // MARK:- Constant

    @IBOutlet weak var withCreditView: UIView!

    @IBOutlet weak var noCreditView: UIView!

    @IBOutlet weak var creditLabel: UILabel!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable
extension CreditHeaderTableViewCell: ViewModelBindable {
    func bind() {
        withCreditView.hidden = viewModel.withCreditViewHidden
        noCreditView.hidden = viewModel.noCreaditViewHidden
        creditLabel.text = viewModel.creditText
    }
}
