//
//  FilterIsOnTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 9/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol FilterIsOnTableViewCellDelegate: class {
    func filterIsOnTableViewCellDidTapReset()
}

final class FilterIsOnTableViewCell: TableViewCell {
    var viewModel: FilterIsOnTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

    weak var delegate: FilterIsOnTableViewCellDelegate?

    @IBOutlet weak var filterTitleLabel: UILabel!

    @IBAction func didTapReset(sender: AnyObject) {
        delegate?.filterIsOnTableViewCellDidTapReset()
    }
}

extension FilterIsOnTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.title.drive(filterTitleLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
    }
}
