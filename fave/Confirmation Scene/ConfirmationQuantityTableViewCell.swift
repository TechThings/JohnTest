//
//  ConfirmationQuantityViewCell.swift
//  FAVE
//
//  Created by Michael Cheah on 09/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class ConfirmationQuantityTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: ConfirmationQuantityViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepperView: KFITStepper!
    @IBOutlet weak var topBorder: UIView!
    @IBOutlet weak var bottomBorder: UIView!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

// MARK:- ViewModelBinldable

extension ConfirmationQuantityTableViewCell: ViewModelBindable {
    func bind() {
        self.titleLabel.text = viewModel.label

        stepperView.maxCount = Int32(viewModel.maxQuantity)

        self.stepperView.rx_controlEvent(.ValueChanged)
        .asDriver()
        .driveNext {
            [weak self] _ -> Void in
            if let currentCount = self?.stepperView.getCurrentCount() {
                self?.viewModel.currentSlot.value = Int(currentCount)
            }
        }.addDisposableTo(rx_reusableDisposeBag)
    }
}
