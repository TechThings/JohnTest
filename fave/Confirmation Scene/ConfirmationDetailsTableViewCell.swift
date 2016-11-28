//
//  ReservationActionDetailsTableViewCell.swift
//  KFIT
//
//  Created by Kevin Mun on 19/03/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class ConfirmationDetailsTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ConfirmationDetailsViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var topBorder: UIView!
    @IBOutlet weak var bottomBorder: UIView!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

// MARK:- ViewModelBinldable

extension ConfirmationDetailsTableViewCell: ViewModelBindable {
    func bind() {
        self.titleLabel.text = viewModel.label
        self.detailsLabel.text = viewModel.details
    }
}
