//
// Created by Michael Cheah on 8/20/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 0

    override func drawTextInRect(rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(self.topInset, self.leftInset, self.bottomInset, self.rightInset))

        super.drawTextInRect(newRect)
    }

}
