//
//  MultipleOutletsViewController.swift
//  FAVE
//
//  Created by Syahmi Ismail on 17/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MultipleOutletsViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var multipleOutletsTableView: MultipleOutletsTableView!

    // MARK:- ViewModel
    var viewModel: MultipleOutletsViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
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
    func setup() {
        let tableViewModel = MultipleOutletsTableViewModel(listing: viewModel.listing)
        tableViewModel.refresh()
        multipleOutletsTableView.viewModel = tableViewModel

        self.title = NSLocalizedString("activity_detail_redeem_offer_text", comment: "")

        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MultipleOutletsViewController.viewControllerCancelDidTap))
    }

    func viewControllerCancelDidTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK:- ViewModelBinldable
extension MultipleOutletsViewController: ViewModelBindable {
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
extension MultipleOutletsViewController: Refreshable {
    func refresh() {
    }
}

// MARK:- Buildable
extension MultipleOutletsViewController: Buildable {
    class func build(builder: MultipleOutletsViewControllerViewModel) -> MultipleOutletsViewController {
        let storyboard = UIStoryboard(name: "MultipleOutlets", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.MultipleOutletsViewController) as! MultipleOutletsViewController
        vc.viewModel = builder
        return vc
    }
}
