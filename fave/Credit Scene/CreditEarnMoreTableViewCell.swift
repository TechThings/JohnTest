//
//  CreditEarnMoreTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class CreditEarnMoreTableViewCell: UITableViewCell {

    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: KFITLabel!
    var referralDescription: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.workButton.setTitle(NSLocalizedString("credit_how_it_work_text", comment: ""), forState: .Normal)
        self.workButton.layer.cornerRadius = 2
        self.workButton.layer.borderWidth = 0.5
        self.workButton.layer.borderColor = UIColor.faveWarmGray().CGColor
        self.workButton.titleEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        self.descriptionLabel.lineSpacing = 2.4
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func workButtonDidTap(sender: AnyObject) {
        wireframeServiceDefault.alertFor(title: NSLocalizedString("credit_dialog_title_text", comment: ""), message: referralDescription!)
    }
}
