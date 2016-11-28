//
//  MyFaveFaveOutletViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 7/7/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MyFaveFaveOutletViewController: ViewController, Scrollable {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: MyFaveFaveOutletViewModel!

    // MARK:- Constant
    var refreshControl = UIRefreshControl()

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        configureRefreshControl()
        registerCell()
        bind()
    }

    func refresh(sender: AnyObject) {
        viewModel.refresh()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_MYFAVE_FAVES)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    deinit {
    }

    private func configureRefreshControl() {
        tableView.addSubview(refreshControl)
        refreshControl.rx_controlEvent(UIControlEvents.ValueChanged)
            .subscribeNext { [weak self] in
                self?.viewModel.refresh()
            }.addDisposableTo(disposeBag)
    }

    private func registerCell() {
        tableView.registerNib(UINib(nibName: "MyFaveFaveOutletSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "MyFaveFaveOutletSearchTableViewCell")
        tableView.registerNib(UINib(nibName: String(OutletsSearchTableViewCell), bundle: nil), forCellReuseIdentifier: String(OutletsSearchTableViewCell))
        tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 15,right: 0)
        tableView.registerNib(UINib(nibName: String(MyFaveEmptyResultTableViewCell), bundle: nil), forCellReuseIdentifier: String(MyFaveEmptyResultTableViewCell))
    }

    func scrollToTop() {
        tableView.setContentOffset(CGPoint.zero, animated:true)
    }
}

extension MyFaveFaveOutletViewController: OutletsSearchTableViewCellModelDelegate {
    func pushViewController(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MyFaveFaveOutletViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.loadingFaveOutletDone ? 2 : 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.isEmptyFaveOutlet.value ? viewModel.suggestionOutlets.value.count : viewModel.faveOutlets.value.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if viewModel.isEmptyFaveOutlet.value {
                let cell = tableView.dequeueReusableCellWithIdentifier(String(MyFaveEmptyResultTableViewCell), forIndexPath: indexPath) as! MyFaveEmptyResultTableViewCell
                cell.messageLabel.text = NSLocalizedString("my_fave_no_favorites", comment: "")
                cell.detailsLabel.text = NSLocalizedString("you_not_add_faves", comment: "")
                cell.detailsLabel.lineSpacing = 2.5
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("MyFaveFaveOutletSearchTableViewCell", forIndexPath: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(OutletsSearchTableViewCell), forIndexPath: indexPath) as! OutletsSearchTableViewCell

            let outlet = viewModel.isEmptyFaveOutlet.value ? viewModel.suggestionOutlets.value[indexPath.row] : viewModel.faveOutlets.value[indexPath.row]

            let cellViewModel = OutletsSearchTableViewCellModel(outlet: outlet, company: outlet.company!)
            cellViewModel.delegate = self
            cell.faveButton.hidden = false
            cell.viewModel = cellViewModel
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.bind()
            return cell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return viewModel.isEmptyFaveOutlet.value ? 250 : 52
        } else {
            return 125
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if !viewModel.isEmptyFaveOutlet.value {
                let outletsSearchViewController = OutletsSearchViewController.build(OutletsSearchViewModel())
                self.navigationController?.pushViewController(outletsSearchViewController, animated: true)
            }
        } else {
            let outlet = viewModel.isEmptyFaveOutlet.value ? viewModel.suggestionOutlets.value[indexPath.row] : viewModel.faveOutlets.value[indexPath.row]

            guard let company = outlet.company else { return }

            let vc = OutletViewController.build(OutletViewControllerViewModel(outletId: outlet.id, companyId: company.id))
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK:- ViewModelBinldable
extension MyFaveFaveOutletViewController: ViewModelBindable {
    func bind() {

        viewModel.faveOutlets.asObservable()
        .observeOn(MainScheduler.instance)
        .subscribeNext { [weak self] _ in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }.addDisposableTo(disposeBag)

        viewModel.isEmptyFaveOutlet.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                self?.viewModel.loadSuggestionOutlets()
            }.addDisposableTo(disposeBag)

        viewModel.suggestionOutlets.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

    }
}

// MARK:- Buildable
extension MyFaveFaveOutletViewController: Buildable {
    final class func build(builder: MyFaveFaveOutletViewModel) -> MyFaveFaveOutletViewController {
        let storyboard = UIStoryboard(name: "MyFave", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(String(MyFaveFaveOutletViewController)) as! MyFaveFaveOutletViewController
        viewController.viewModel = builder
        builder.refresh()
        return viewController
    }
}

extension MyFaveFaveOutletViewController: DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> MyFaveFaveOutletViewController? {
        return build(MyFaveFaveOutletViewModel())
    }
}
