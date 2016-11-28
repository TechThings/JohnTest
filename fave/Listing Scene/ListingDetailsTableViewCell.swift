//
//  ListingDetailsTableViewCell.swift
//  FAVE
//
//  Created by Kevin Mun on 23/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class ListingDetailsTableViewCell: TableViewCell {

    var viewModel: ListingDetailsTableViewCellViewModel!

    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension ListingDetailsTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .title
            .asDriver()
            .driveNext {
                [weak self] (title: String) in
                self?.activityTitleLabel.text = title
                self?.activityTitleLabel.sizeToFit()
            }
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .currentPrice
            .asDriver()
            .drive(currentPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .originalPrice
            .asDriver()
            .driveNext { [weak self] (originalPrice: String) in
                self?.originalPriceLabel.text = originalPrice
                if self?.originalPriceLabel.text == ""{
                    self?.originalPriceLabel.removeFromSuperview()
                }
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}
