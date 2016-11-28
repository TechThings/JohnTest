//
//  UIView.swift
//
//  Created by Nazih Shoura on 03/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UIView {
    final class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

extension UIView {
    func removeAllSubViews() {
        self.subviews.forEach({ $0.removeFromSuperview() })
    }
}

extension UIView {
    func resizeToFitSubviews() {
        var viewWidth: CGFloat = 0
        var viewHeight: CGFloat = 0

        for subview in self.subviews {
            let subviewWidth = subview.frame.origin.x + subview.frame.size.width
            let subviewHeight = subview.frame.origin.y + subview.frame.size.height
            viewWidth = max(viewWidth, subviewWidth)
            viewHeight = max(viewHeight, subviewHeight)
        }

        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, viewWidth, viewHeight)
    }
}

extension UIView {
    func addTopBorder(width: CGFloat, color: UIColor = UIColor.blackColor()) {
        addBorder(color, frame: CGRect(x: 0, y: 0, width: frame.width, height: width))
    }

    func addBottomBorder(width: CGFloat, color: UIColor = UIColor.blackColor()) {
        addBorder(color, frame: CGRect(x: 0, y: frame.height - width, width: frame.width, height: width))
    }

    func addLeftBorder(width: CGFloat, color: UIColor = UIColor.blackColor()) {
        addBorder(color, frame: CGRect(x: 0, y: 0, width: width, height: frame.height))
    }

    func addRightBorder(width: CGFloat, color: UIColor = UIColor.blackColor()) {
        addBorder(color, frame: CGRect(x: frame.width / 2 + 8, y: 0, width: width, height: frame.height))
    }

    private func addBorder(color: UIColor, frame: CGRect) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = frame

        layer.addSublayer(border)
        //layer.masksToBounds = true
    }
}

// R: Should add the borderWidth as a parameter, Otherwise the method will have an undocumented side effect of changing the borderWidth to 1
extension UIView {
    func roundedView(radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat = 1.0) {
        self.clipsToBounds = false
        self.layer.borderColor = borderColor.CGColor
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
    }
}
