//
//  ChangeStagingSubmitTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

@objc protocol ChangeStagingSubmitDelegate {
    func changeStagingDidChange()
}

final class ChangeStagingSubmitTableViewCell: UITableViewCell {

    weak var delegate: ChangeStagingSubmitDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func didTapSubmitButton(sender: AnyObject) {
        delegate?.changeStagingDidChange()
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
