//
//  UserDetailTableViewCell.swift
//  fave
//
//  Created by Michael Cheah on 7/14/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserDetailTableViewCell: TableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    // MARK:- ViewModel
    var viewModel: UserDetailViewModel!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        // Nothing as of now
    }
}

// MARK:- ViewModelBinldable
extension UserDetailTableViewCell: ViewModelBindable {
    func bind() {
        self.titleLabel.text = viewModel.title.capitalizedString
        self.detailsLabel.text = viewModel.details
    }
}
