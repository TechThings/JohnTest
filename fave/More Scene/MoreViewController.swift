//
//  MoreViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MoreViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: MoreViewModel!

    // MARK:- Constant
    let tableViewCellHeight: CGFloat = 64
    let tableViewHeaderHeight: CGFloat = 160

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBarHidden = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_MORE)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBarHidden = false
    }

    func setup() {
        tableView.registerNib(UINib(nibName: String(MoreTableViewCell), bundle: nil), forCellReuseIdentifier: String(MoreTableViewCell))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = MoreTableViewHeaderView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), tableViewHeaderHeight))

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
}

extension MoreViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MoreTableViewCell

        let viewControllerPresentingStyle = cell.viewModel.viewControllerPresentingStyleGenerator()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch viewControllerPresentingStyle.presentationStyle {
        case .Push:
            self.navigationController?.pushViewController(viewControllerPresentingStyle.viewController as! UIViewController, animated: true)
        case .Modal:
            self.presentViewController(viewControllerPresentingStyle.viewController as! UIViewController, animated: true, completion: nil)
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewCellHeight
    }
}

extension MoreViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.moreTableViewCellViewModels.value.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(MoreTableViewCell), forIndexPath: indexPath) as! MoreTableViewCell
        cell.viewModel = viewModel.moreTableViewCellViewModels.value[indexPath.row]
        cell.bind()
        return cell
    }
}

// MARK:- ViewModelBinldable
extension MoreViewController: ViewModelBindable {
    func bind() {
        viewModel
            .moreTableViewCellViewModels
            .asDriver()
            .driveNext {
                [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        viewModel
            .isCurrentUserAguest
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext {
                [weak self] in
                if $0 {
                    let nvc = self?.navigationController
                    let vc = GuestViewController.build(GuestViewControllerViewModel())
                    nvc?.popToRootViewControllerAnimated(true)
                    nvc?.setViewControllers([vc], animated: false)
                }
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension MoreViewController: Refreshable {
    func refresh() {
        viewModel.refresh()
    }
}

// MARK:- Build
extension MoreViewController: Buildable {
    final class func build(builder: MoreViewModel) -> MoreViewController {
        let storyboard = UIStoryboard(name: "More", bundle: nil)
        let moreViewController = storyboard.instantiateViewControllerWithIdentifier(String(MoreViewController)) as! MoreViewController
        moreViewController.viewModel = builder
        return moreViewController
    }
}
