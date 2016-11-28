//
//  ReservationActionPriceTableViewCell.swift
//  KFIT
//
//  Created by Kevin Mun on 22/03/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift

final class ConfirmationFinalPriceTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ConfirmationFinalPriceViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: KFITLabel!
    @IBOutlet weak var bottomBorder: UIView!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

// MARK:- ViewModelBinldable

extension ConfirmationFinalPriceTableViewCell: ViewModelBindable {
    func bind() {
        self.titleLabel.text = viewModel.label

        viewModel.finalPrice
        .driveNext {
            [weak self] in
            self?.currentPriceLabel.text = $0
        }.addDisposableTo(rx_reusableDisposeBag)
    }
}
