//
//  ListingsViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 7/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

final class ListingsViewController: ViewController {

    @IBOutlet weak var tableView: ListingsTableView! {
        didSet {
            self.setup()
        }
    }

//    // MARK:- ViewModel
    var viewModel: ListingsViewModel!

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
    }

    func setup() {
        let tableViewModel = ListingsTableViewModel(functionality: viewModel.functionality, state: ListingsViewModelState(page: 1, loadedEverything: false, subCategories: [], categoryType: viewModel.category.type, order: nil, priceRanges: nil, distances: nil, category: viewModel.category), location: viewModel.location)
        tableView.viewModel = tableViewModel
    }

    func passLocationObservable(location: Variable<CLLocation?>) {
        location.asObservable().bindTo(viewModel.location).addDisposableTo(disposeBag)
    }
}

// MARK:- ViewModelBinldable
extension ListingsViewController: ViewModelBindable {
    func bind() {
        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                // Problem: We load current and next page at the same time so can not filter with listingsViewController.viewModel.active cause have more than 1 active viewController
                // Solution: Can only check the current active viewController by filter via NearbyViewController current page. So if NearbyViewController is active and current page is self then return true

                guard let strongSelf = self else {return false}

                guard let nearbyNVC = RootTabBarController.shareInstance?.viewControllers?[RootTabBarControllerTab.nearby.rawValue] as? RootNavigationController else {
                    return false
                }

                guard let nearbyVC = nearbyNVC.topViewController as? NearbyViewController else {
                    return false
                }

                guard nearbyVC.viewModel.isActive else {
                    if strongSelf.viewModel.isActive {
                        return true
                    }
                    return false
                }

                guard let currentPage = nearbyVC.getCurrentPage() else {
                    return false
                }

                return currentPage == strongSelf
            }
            .subscribeNext { [weak self] (navigationClosure: NavigationClosure) in
                guard let strongSelf = self else { return }
                navigationClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension ListingsViewController: Refreshable {
    func refresh() {
        viewModel.refresh()
    }
}

// MARK:- Buildable
extension ListingsViewController: Buildable {
    final class func build(builder: ListingsViewModel) -> ListingsViewController {
        let storyboard = UIStoryboard(name: "Listings", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(String(ListingsViewController)) as! ListingsViewController
        viewController.viewModel = builder
        return viewController
    }
}
