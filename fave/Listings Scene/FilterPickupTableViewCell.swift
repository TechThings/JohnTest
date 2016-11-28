//
//  FilterPickupTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/25/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

class FilterPickupTableViewCell: UITableViewCell {

    var viewModel: FilterPickupTableViewCellViewModel!

    @IBOutlet weak var orderButton: UIButton!

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension FilterPickupTableViewCell: ViewModelBindable {
    func bind() {
        titleLabel.text = viewModel.countPlaceNearbyLabelText
        orderButton.setTitle(viewModel.orderButtonTitle, forState: UIControlState.Normal)
    }
}
