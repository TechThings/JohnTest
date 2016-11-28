//
//  HomeViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MoEngage_iOS_SDK

final class HomeViewController: ViewController, Scrollable {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: HomeTableView!

    // MARK:- ViewModel
    var viewModel: HomeViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.popWriteReviewVC()
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_HOME)

        MoEngage.sharedInstance().handleInAppMessage()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false

    }

    func scrollToTop() {
        tableView.setContentOffset(CGPoint.zero, animated:true)
    }

    func setup() {
        let homeTableViewModel = HomeTableViewModel()
        homeTableViewModel.refresh()
        tableView.viewModel = homeTableViewModel
        tableView.tableFooterView = nil
    }
}

// MARK:- ViewModelBinldable
extension HomeViewController: ViewModelBindable {
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
            .writeReviewVC
            .asDriver()
            .filterNil()
            .driveNext { [weak self] (vc) in
                self?.presentViewController(vc, animated: true, completion: nil)
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable
extension HomeViewController: Buildable {
    final class func build(builder: HomeViewControllerViewModel) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.HomeViewController) as! HomeViewController
        vc.viewModel = builder
        return vc
    }
}
