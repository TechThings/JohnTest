//
//  RootNavigationController.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class RootNavigationController: NavigationController {
    var viewModel: RootNavigationViewModel!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if viewModel.setAsRoot { self.view.window?.rootViewController = self}
    }

}

extension RootNavigationController: ViewModelBindable {
    func bind() {
    }
}

extension RootNavigationController: Buildable {
    final class func build(builder: RootNavigationViewModel) -> RootNavigationController {
        let storyboard = UIStoryboard(name: "RootNavigationController", bundle: nil)
        let rootNavigationController = storyboard.instantiateViewControllerWithIdentifier(String(RootNavigationController)) as! RootNavigationController
        rootNavigationController.viewModel = builder
        return rootNavigationController
    }
}
