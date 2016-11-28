//
//  UINavigationController.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/21/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

extension UINavigationController {
    func popViewController(animated: Bool, completion: Void -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewControllerAnimated(animated)
        CATransaction.commit()
    }
    func pushViewController(viewController: UIViewController,
                            animated: Bool, completion: Void -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
