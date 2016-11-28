//
//  UILabel.swift
//  FAVE
//
//  Created by Thanh KFit on 6/21/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

extension UILabel {
    func getContentWidth() -> CGFloat {
        return (self.text?.widthWithConstrainedHeight(self.frame.size.height, font: self.font))!
    }

    func getContentHeight() -> CGFloat {
        return (self.text?.heightWithConstrainedWidth(self.frame.size.width, font: self.font))!
    }
}
