//
//  BorderedView.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

@IBDesignable
private class BorderedView: UIView {
    @IBInspectable private var borderWidth: CGFloat = 0
    @IBInspectable private var borderColor: UIColor = UIColor.blackColor()

    @IBInspectable private var showsTopBorder: Bool = false
    @IBInspectable private var showsBottomBorder: Bool = false
    @IBInspectable private var showsLeftBorder: Bool = false
    @IBInspectable private var showsRightBorder: Bool = false

    private override func awakeFromNib() {
        super.awakeFromNib()

        if (showsTopBorder || showsBottomBorder || showsLeftBorder || showsRightBorder) && borderWidth == 0 {
            borderWidth = 1
        }

        if showsTopBorder {
            addTopBorder(borderWidth, color: borderColor)
        }
        if showsBottomBorder {
            addBottomBorder(borderWidth, color: borderColor)
        }
        if showsLeftBorder {
            addLeftBorder(borderWidth, color: borderColor)
        }
        if showsRightBorder {
            addRightBorder(borderWidth, color: borderColor)
        }
    }
}
