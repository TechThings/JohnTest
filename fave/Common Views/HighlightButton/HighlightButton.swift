//
//  HighlightButton.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

@IBDesignable
class HighlightButton: UIButton {
    private var normalBackgroundColor: UIColor!

    @IBInspectable var highlightedBackgroundColor: UIColor = UIColor.lightGrayColor()

    override func awakeFromNib() {
        super.awakeFromNib()
        normalBackgroundColor = backgroundColor
    }

    override var highlighted: Bool {
        didSet {
            if highlighted {
                backgroundColor = highlightedBackgroundColor
            } else {
                backgroundColor = normalBackgroundColor
            }
        }
    }
}
