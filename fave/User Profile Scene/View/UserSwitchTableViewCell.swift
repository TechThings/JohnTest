//
//  UserSwitchTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class UserSwitchTableViewCell: UITableViewCell {

    var viewModel: UserSwitchViewModel!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var switchControl: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension UserSwitchTableViewCell: ViewModelBindable {
    func bind() {
        self.titleLabel.text = viewModel.title
        self.switchControl.setOn(viewModel.value, animated: false)
    }
}
