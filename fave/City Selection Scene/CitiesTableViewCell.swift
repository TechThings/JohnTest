//
//  CitiesTableViewCell.swift
//  FAVE
//
//  Created by Kevin Mun on 10/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class CitiesTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }

    func setup() {
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
