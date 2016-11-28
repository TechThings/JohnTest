//
//  ViewAllReservationTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class ViewAllReservationTableViewCell: UITableViewCell {

    @IBOutlet weak var pastPurchasesTitle: UILabel!
    @IBOutlet weak var pastPurchaseView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        pastPurchaseView.layer.cornerRadius = 3
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
