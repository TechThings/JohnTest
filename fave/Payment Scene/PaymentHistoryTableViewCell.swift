//
// Created by Michael Cheah on 7/10/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class PaymentHistoryTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: PaymentHistoryTableViewCellViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var separatorCustomView: UIView!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var referenceIdLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension PaymentHistoryTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.creatDate.drive(createDateLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.price.drive(priceLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.referenceId.drive(referenceIdLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.title.drive(titleLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.status.drive(statusLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
    }
}
