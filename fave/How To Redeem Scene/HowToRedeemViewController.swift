//
//  HowToRedeemViewController.swift
//  FAVE
//
//  Created by Syahmi Ismail on 24/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HowToRedeemViewController: ViewController {

    // MARK:- IBOutlet

    // MARK:- ViewModel
    var viewModel: HowToRedeemViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MultipleOutletsViewController.viewControllerCancelDidTap))
        self.navigationItem.title = NSLocalizedString("purchase_detail_how_to_redeem", comment:"")
    }

    func viewControllerCancelDidTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
}

// MARK:- ViewModelBinldable
extension HowToRedeemViewController: ViewModelBindable {
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
extension HowToRedeemViewController: Refreshable {
    func refresh() {
    }
}

// MARK:- Buildable
extension HowToRedeemViewController: Buildable {
    class func build(builder: HowToRedeemViewControllerViewModel) -> ViewController {
        let storyboard = UIStoryboard(name: "HowToRedeem", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.HowToRedeemViewController) as! HowToRedeemViewController
        vc.viewModel = builder
        return vc
    }
}
