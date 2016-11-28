//
//  NextSessionsDateHeaderView.swift
//  FAVE
//
//  Created by Thanh KFit on 7/29/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class NextSessionsDateHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var separatorHeight: NSLayoutConstraint!

    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        self.separatorHeight.constant = 1/UIScreen.mainScreen().scale
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
