//
//  InsetTextField.swift
//  KFIT
//
//  Created by Nazih Shoura on 08/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class InsetTextField: UITextField {

    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }

    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
