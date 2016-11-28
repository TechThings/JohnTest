//
//  FilterIsOffTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 9/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FilterIsOffTableViewCell: TableViewCell {
    var viewModel: FilterIsOffTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var filterTitleLabel: UILabel!
}

extension FilterIsOffTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.title.drive(filterTitleLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
    }
}
