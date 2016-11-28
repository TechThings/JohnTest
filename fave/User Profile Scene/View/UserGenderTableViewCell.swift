//
//  UserGenderTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class UserGenderTableViewCell: UITableViewCell {

    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
