//
//  EmptyNearbyViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 10/24/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class EmptyNearbyViewController: ViewController {

    // MARK:- IBOutlet

    // MARK:- ViewModel
    var viewModel: EmptyNearbyViewControllerViewModel!

    @IBOutlet weak var tryAgainButton: UIButton!
    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tryAgainButton.setTitle(NSLocalizedString("msg_error_button", comment: ""), forState: .Normal)
        bind()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func didTapTryAgainButton(sender: AnyObject) {
        viewModel.tryAgainButtonDidTap.onNext()
    }
}

// MARK:- ViewModelBinldable
extension EmptyNearbyViewController: ViewModelBindable {
    func bind() {
        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive
            }
            .subscribeNext { [weak self] (navigationClosure: NavigationClosure) in
                guard let strongSelf = self else { return }
                navigationClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension EmptyNearbyViewController: Refreshable {
    func refresh() {
        viewModel.refresh()
    }
}

// MARK:- Buildable
extension EmptyNearbyViewController: Buildable {
    class func build(builder: EmptyNearbyViewControllerViewModel) -> EmptyNearbyViewController {
        let storyboard = UIStoryboard(name: "EmptyNearby", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.EmptyNearbyViewController) as! EmptyNearbyViewController
        vc.viewModel = builder
        return vc
    }
}
