//
//  ChildViewControllerDelegate.swift
//  KFIT
//
//  Created by Nazih Shoura on 01/01/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import UIKit

protocol ChildViewController {
    func setChildViewControllerDelegate(delegate: ChildViewControllerDelegate)
}

protocol ChildViewControllerDelegate: class {
    func childViewControllerShouldDisappear(childViewController: UIViewController)
}
