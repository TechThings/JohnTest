//
//  ListingMultipleOutletsTableViewCell.swift
//  FAVE
//
//  Created by Syahmi Ismail on 17/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingMultipleOutletsTableViewCell: TableViewCell {

    // MARK:- @IBOutlet
    @IBOutlet weak var totalOutletLabel: UILabel!

    var viewModel: ActivityMultipleOutletsCellViewModel! {
        didSet {
            bind()
        }
    }
}

extension ListingMultipleOutletsTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .totalOutlet
            .drive(totalOutletLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
