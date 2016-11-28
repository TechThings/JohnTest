//
//  NextSessionsTimeSlotTableViewCell.swift
//  FAVE
//
//  Created by Kevin Mun on 23/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NextSessionsTimeSlotTableViewCell: TableViewCell {

    var viewModel: NextSessionsTimeSlotTableViewCellViewModel!

    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var slotLabel: KFITBoxedLabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        slotLabel.layer.cornerRadius = 2.0
        bookButton.layer.cornerRadius = 2.0
    }
}

extension NextSessionsTimeSlotTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.slotText
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.slotLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.timeText
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.timeLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.slotHidden
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.slotLabel.hidden = $0
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}
