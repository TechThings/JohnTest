//
//  ListingBuyNowTableViewCell.swift
//  FAVE
//
//  Created by Kevin Mun on 23/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingBuyNowTableViewCell: TableViewCell {

    @IBOutlet weak var redeemLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slotsLeftLabel: KFITBoxedLabel!

    var viewModel: ListingBuyNowTableViewCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension ListingBuyNowTableViewCell: ViewModelBindable {
    func bind() {

        viewModel.dateText
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (dateText: String) in
                if dateText == "" {
                    self?.redeemLabel.text = ""
                }
                self?.timeLabel.text = dateText
            }.addDisposableTo(rx_reusableDisposeBag)

        slotsLeftLabel.hidden = viewModel.slotLeftHidden
        slotsLeftLabel.text = viewModel.slotLeftText
    }
}
