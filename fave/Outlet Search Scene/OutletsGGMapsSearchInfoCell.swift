//
//  OutletsGGMapsSearchInfoCell.swift
//  FAVE
//
//  Created by Thanh KFit on 6/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift

final class OutletsGGMapsSearchInfoCell: TableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    var viewModel: OutletsGGMapsSearchInfoCellViewModel!
}

extension OutletsGGMapsSearchInfoCell: ViewModelBindable {
    func bind() {
        viewModel.message
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { (message) in
                self.messageLabel.text = message
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}
