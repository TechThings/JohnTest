//
//  ListingsGroupedAllOffersViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 10/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingsGroupedAllOffersViewController: ViewController {

    // MARK:- IBOutlet

    @IBOutlet weak var tableView: ListingsGroupedAllOffersTableView! {
        didSet {
            let tableViewModel = ListingsGroupedAllOffersTableViewModel(outlet: viewModel.outlet)
            tableView.viewModel = tableViewModel
        }
    }

    // MARK:- ViewModel
    var viewModel: ListingsGroupedAllOffersViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

// MARK:- ViewModelBinldable
extension ListingsGroupedAllOffersViewController: ViewModelBindable {
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

        viewModel
            .title
            .driveNext { [weak self] (title) in
                self?.navigationItem.title = title
            }.addDisposableTo(disposeBag)

        // navigationItem.title = viewModel.outlet.company?.name

    }
}

// MARK:- Buildable
extension ListingsGroupedAllOffersViewController: Buildable {
    class func build(builder: ListingsGroupedAllOffersViewControllerViewModel) -> ListingsGroupedAllOffersViewController {
        let storyboard = UIStoryboard(name: literal.ListingsGroupedAllOffers, bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.ListingsGroupedAllOffersViewController) as! ListingsGroupedAllOffersViewController
        vc.viewModel = builder
        return vc
    }
}
