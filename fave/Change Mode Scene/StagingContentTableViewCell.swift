//
//  StagingContentTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/29/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class StagingContentTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedCheckBox: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        // Initialization code
    }
}
