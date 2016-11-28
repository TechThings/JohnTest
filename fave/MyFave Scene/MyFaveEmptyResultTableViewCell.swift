//
//  MyFaveEmptyResultTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class MyFaveEmptyResultTableViewCell: UITableViewCell {

    var viewModel: MyFaveEmptyResultTableViewCellViewModel! {
        didSet {
            bind()
        }
    }
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var detailsLabel: KFITLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        detailsLabel.lineSpacing = 2.5
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension MyFaveEmptyResultTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.message.drive(messageLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.details.drive(detailsLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
    }
}
