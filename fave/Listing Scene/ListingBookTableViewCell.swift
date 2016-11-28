//
//  ListingBookTableViewCell.swift
//  FAVE
//
//  Created by Kevin Mun on 23/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingBookTableViewCell: TableViewCell {

    var viewModel: ListingBookTableViewCellViewModel!

    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var slotLabel: KFITBoxedLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        slotLabel.layer.cornerRadius = 2.0
        bookButton.layer.cornerRadius = 2.0
    }
}

extension ListingBookTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .slotText
            .asDriver()
            .drive(slotLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .timeText
            .asDriver()
            .drive(timeLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .dateText
            .asDriver()
            .drive(dateLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .slotHidden
            .asDriver()
            .drive(slotLabel.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
