//
//  ReservationActionPriceTableViewCell.swift
//  KFIT
//
//  Created by Kevin Mun on 22/03/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift

final class ConfirmationPriceTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ConfirmationPriceViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var promoSavingsLabel: KFITBoxedLabel!
    @IBOutlet weak var originalPriceLabel: KFITLabel!
    @IBOutlet weak var currentPriceLabel: KFITLabel!
    @IBOutlet weak var bottomBorder: UIView!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

// MARK:- ViewModelBinldable

extension ConfirmationPriceTableViewCell: ViewModelBindable {
    func bind() {
        self.titleLabel.text = viewModel.label

        viewModel
            .originalPrice
            .drive(originalPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .currentPrice
            .drive(currentPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
