//
//  NavigationController.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import SwiftLoader

class NavigationController: UINavigationController {
    var disposeBag = DisposeBag()
    /// Track the ViewController activities
    let networkActivityIndicator = ActivityIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Activate the nextwork
    }

}
