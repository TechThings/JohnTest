//
//  ListingReviewHeaderSectionView.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class ListingReviewHeaderSectionView: UIView {

    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        separatorHeightConstraint.constant = 1.0/UIScreen.mainScreen().scale

        self.reviewsButton.setTitle(NSLocalizedString("activity_detail_view_all_text", comment: ""), forState: .Normal)

    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
