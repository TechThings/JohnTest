//
//  CanceledReservationViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 14/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CanceledReservationViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: CanceledReservationViewCellViewModel!

    // MARK:- Constant

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable
extension CanceledReservationViewCell: ViewModelBindable {
    func bind() {
        messageLabel.text = viewModel.message
        titleLabel.text = viewModel.title
        iconImageView.image = viewModel.icon
    }
}
