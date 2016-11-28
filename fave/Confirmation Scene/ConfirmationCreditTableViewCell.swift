//
//  ReservationActionPriceTableViewCell.swift
//  KFIT
//
//  Created by Kevin Mun on 22/03/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift

final class ConfirmationCreditTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ConfirmationCreditViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomBorder: UIView!
    @IBOutlet weak var creditLabel: KFITLabel!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

// MARK:- ViewModelBinldable

extension ConfirmationCreditTableViewCell: ViewModelBindable {
    func bind() {
        self.titleLabel.text = viewModel.label

        viewModel
            .creditUsed
            .drive(creditLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
