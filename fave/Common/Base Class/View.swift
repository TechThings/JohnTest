//
//  View.swift
//
//  Created by Nazih Shoura on 20/05/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import UIKit
import RxSwift

class View: UIView {
    var disposeBag = DisposeBag()
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
}
