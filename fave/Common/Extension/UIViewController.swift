//
//  UIViewController+EndEditing.swift
//
//  Created by Nazih Shoura on 19/05/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import UIKit

extension UIViewController {

    /// End editing when tap on background, Default value is true
    func endEditingWhenTapOnBackground(shouldEndEditingWhenTapOnBackground: Bool) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.endEditing))
        shouldEndEditingWhenTapOnBackground ? view.addGestureRecognizer(tap) : view.removeGestureRecognizer(tap)
    }

    @objc
    private func endEditing() {
        view.endEditing(true)
    }
}
