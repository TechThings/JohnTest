//
//  OutletsSearchViewController.swift
//  KFIT
//
//  Created by Nazih Shoura on 12/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import QuartzCore

final class OutletsSearchViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarTextFeild: UITextField!
    @IBOutlet weak var outletOrderSegmentedControl: UISegmentedControl!

    @IBOutlet weak var outletsMapView: OutletsMapView!

    @IBOutlet weak var outletOrderSegmentedControlContainerView: UIView!
    @IBOutlet weak var switchMapTableButton: UIButton!
    @IBOutlet weak var switchMapTableImageView: UIImageView!
    @IBOutlet weak var searchBarTextFeildContainerView: UIView!
    @IBOutlet weak var searchBarSegmentedControlView: UIView!
    @IBOutlet weak var searchBarSegmentedControlViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentedControlViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarViewHeightConstraint: NSLayoutConstraint!

    var viewModel: OutletsSearchViewModel!
    var spinner: UIActivityIndicatorView!

    let indexOffSetToStartLoadingAt: Int = 10
    let rowOutletHeight: CGFloat = 125
    let rowGGMapsOutletInfoHeight: CGFloat = 130
    let rowGGMapsOutletHeight: CGFloat = 90

    var outletOrderSegmentedControlContainerViewOriginalFrame: CGRect!

    private func configureSegmentControl() {
        outletOrderSegmentedControl.setTitle(NSLocalizedString("sort_by_distance_option", comment: ""), forSegmentAtIndex: 0)
        outletOrderSegmentedControl.setTitle(NSLocalizedString("search_map_most_faves_text", comment: ""), forSegmentAtIndex: 1)

        outletOrderSegmentedControlContainerViewOriginalFrame = outletOrderSegmentedControlContainerView.frame
        outletOrderSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(13)], forState: .Normal)
    }

    private func configureTableView() {
        tableView.registerNib(UINib(nibName:String(OutletsSearchTableViewCell), bundle: nil), forCellReuseIdentifier: String(OutletsSearchTableViewCell))
        tableView.registerNib(UINib(nibName: String(OutletsGGMapsSearchCell), bundle: nil), forCellReuseIdentifier: String(OutletsGGMapsSearchCell))
        tableView.registerNib(UINib(nibName: String(OutletsGGMapsSearchInfoCell), bundle: nil), forCellReuseIdentifier: String(OutletsGGMapsSearchInfoCell))

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .OnDrag
    }

    private func configuresearchBarTextFeild() {
        searchBarTextFeild.returnKeyType = .Done
        searchBarTextFeild.enablesReturnKeyAutomatically = false
        searchBarTextFeildContainerView.layer.cornerRadius = 5

        searchBarTextFeild
            .rx_text
            .skip(1) // Skip the first emmition as we we are not interested in the first value
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext { [weak self] _ in
                if let strongSelf = self {
                    if !strongSelf.outletsMapView.hidden { strongSelf.switchMapTable() }
                }
            }.addDisposableTo(disposeBag)
    }

    private func configureSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 50)
        tableView.tableFooterView = spinner

        networkActivityIndicator
            .drive(spinner.rx_animating)
            .addDisposableTo(disposeBag)
    }

    private func configureMapView() {
        let outletsMapViewModel = OutletsMapViewModel()
        outletsMapView.viewModel = outletsMapViewModel
        outletsMapView.viewModel.refresh()
        outletsMapView.bind()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchBarTextFeild.becomeFirstResponder()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_SEARCH_PAGE)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = OutletsSearchViewModel()

        configureTableView()

        configureSegmentControl()

        configuresearchBarTextFeild()

        configureSpinner()

        showTable()

        configureMapView()

        networkActivityIndicator.trackActivityIndicator(viewModel.activityIndicator)

        bind()

    }

    @IBAction func backButtonDidTap(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func didTapSwitchMapButton(sender: AnyObject) {
        switchMapTable()
    }
    private func switchMapTable() {
        let tableToMapView = self.outletsMapView.hidden

        if tableToMapView {
            self.searchBarSegmentedControlViewHeightConstraint.constant = self.searchBarSegmentedControlViewHeightConstraint.constant - self.segmentedControlViewHeightConstraint.constant
        } else {
            self.searchBarSegmentedControlViewHeightConstraint.constant = self.searchBarSegmentedControlViewHeightConstraint.constant + self.segmentedControlViewHeightConstraint.constant
        }

        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }

        UIView.animateWithDuration(0.2, animations: { [weak self] _ in
            if tableToMapView {
                self?.tableView.alpha = 0
                self?.outletsMapView.alpha = 1
            } else {
                self?.tableView.alpha = 1
                self?.outletsMapView.alpha = 0
            }
            }, completion: { [weak self] completed in
                if tableToMapView {
                    self?.showMap()
                } else {
                    self?.showTable()
                }
            })
    }

    private func showTable() {
        tableView.hidden = false
        outletsMapView.hidden = true
        switchMapTableImageView.image = viewModel.switchTableActiveImage
    }

    private func showMap() {
        outletsMapView.viewModel.outletsToFocusOn.value = viewModel.outlets.value
        outletsMapView.viewModel.refresh()

        tableView.hidden = true
        outletsMapView.hidden = false
        switchMapTableImageView.image = self.viewModel.switchMapActiveImage
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true

        // FIXM: Very big CC here. Not sure why the selected Segment did changed after viewDidLoad
        outletOrderSegmentedControl.selectedSegmentIndex = 0
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        OutletsMapViewModel.outletsCache.removeAll(keepCapacity: false)
    }
}

extension OutletsSearchViewController: OutletsSearchTableViewCellModelDelegate {
    func pushViewController(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension OutletsSearchViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !viewModel.isEmptyOutletsSearch.value {
            let outlet = viewModel.outlets.value[indexPath.row]
            guard let company = outlet.company else { return }

            let vc = OutletViewController.build(OutletViewControllerViewModel(outletId: outlet.id, companyId: company.id))
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !viewModel.isEmptyOutletsSearch.value {
            if viewModel.outlets.value.count - indexPath.row == indexOffSetToStartLoadingAt {
                viewModel.loadNextPage()
            }
        }
    }
}

extension OutletsSearchViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !viewModel.isEmptyOutletsSearch.value {
            return viewModel.outlets.value.count
        } else {
            return viewModel.outletsGGMapsSearch.value.count + 1
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !viewModel.isEmptyOutletsSearch.value {
            return rowOutletHeight
        } else {
            if indexPath.row == 0 {
                return rowGGMapsOutletInfoHeight
            } else {
                return rowGGMapsOutletHeight
            }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (!viewModel.isEmptyOutletsSearch.value) {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(OutletsSearchTableViewCell), forIndexPath: indexPath) as! OutletsSearchTableViewCell
            let outlet = viewModel.outlets.value[indexPath.row]
            let cellViewModel = OutletsSearchTableViewCellModel(outlet: outlet, company: outlet.company!)
            cellViewModel.delegate = self
            cell.viewModel = cellViewModel
            cell.bind()
            return cell
        } else {
            if indexPath.row == 0 {
                let message = viewModel.getGGMapsOutletsInfomation()
                let cellViewModel = OutletsGGMapsSearchInfoCellViewModel(mess: message)

                let cell = tableView.dequeueReusableCellWithIdentifier(String(OutletsGGMapsSearchInfoCell), forIndexPath: indexPath) as! OutletsGGMapsSearchInfoCell
                cell.viewModel = cellViewModel
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.bind()
                return cell
            } else {
                let cellViewModel = OutletsGGMapsSearchCellViewModel(outletGGMapsSearch: viewModel.outletsGGMapsSearch.value[indexPath.row - 1])
                let cell = tableView.dequeueReusableCellWithIdentifier(String(OutletsGGMapsSearchCell), forIndexPath: indexPath) as! OutletsGGMapsSearchCell
                cell.viewModel = cellViewModel
                cell.selectionStyle = UITableViewCellSelectionStyle.None
//                cell.delegate = self
                cell.bind()
                return cell
            }
        }
    }
}

//extension OutletsSearchViewController: FavoriteProviderDelegate {
//    func favoriteDidUpdate(outlet: Outlet) {
//        viewModel.updateFavorite(outlet.id, favoriteId: outlet.favoriteId)
//    }
//}
//
//extension OutletsSearchViewController : OutletGGMapsSearchCellDelegate {
//    func didTapFaveButton(id: String) {
//        viewModel.updateCrowdedSourceFavorite(id)
//        self.tableView.reloadData()
//    }
//}

extension OutletsSearchViewController: ViewModelBindable {
    func bind() {

        outletOrderSegmentedControl
            .rx_value
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { return Observable.just(OutletsOrder(rawValue: $0)!) }
            .subscribeNext { [weak self] outletOrder in
                if let strongSelf = self {
                    strongSelf.viewModel.searchOutletsForQuery(strongSelf.searchBarTextFeild.text!, outletOrder: outletOrder)
                }
            }.addDisposableTo(disposeBag)

        searchBarTextFeild
            .rx_text
            .skip(1)
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { return Observable.just($0) }
            .subscribeNext { [weak self] query in
                if let strongSelf = self {
                    strongSelf.viewModel.searchOutletsForQuery(query, outletOrder: OutletsOrder(rawValue: strongSelf.outletOrderSegmentedControl.selectedSegmentIndex)!)
                }
            }.addDisposableTo(disposeBag)

        viewModel
            .outlets
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                if $0.count > 0 {
                    self?.tableView.reloadData()
                }
            }.addDisposableTo(disposeBag)

        viewModel
            .isEmptyOutletsSearch
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                if $0 {
                    self?.viewModel.loadGGMapsOutlet()
                }
            }.addDisposableTo(disposeBag)

        viewModel
            .outletsGGMapsSearch
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        viewModel.searchBarTextFieldPlaceholder.asObservable().subscribeNext { [weak self] placeholder in
            self?.searchBarTextFeild.placeholder = placeholder
            }.addDisposableTo(disposeBag)

        viewModel
            .viewModelState
            .asObservable()
            .take(1) // only update the search text and the segment control the first time we bind so the the UI comfirms with the view model initial state. After that, the UI will update the view model state
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (outletsSearchViewModelState) in
                self?.outletOrderSegmentedControl.selectedSegmentIndex = outletsSearchViewModelState.outletOrder.rawValue
                self?.searchBarTextFeild.text = outletsSearchViewModelState.query
            }.addDisposableTo(disposeBag)
    }
}

extension OutletsSearchViewController: Buildable {
    static func build(builder: OutletsSearchViewModel) -> OutletsSearchViewController {
        let storyboard = UIStoryboard(name: "OutletsSearch", bundle: NSBundle.mainBundle())
        let outletsSearchViewController = storyboard.instantiateViewControllerWithIdentifier(String(OutletsSearchViewController)) as! OutletsSearchViewController
        let viewModel = OutletsSearchViewModel()
        outletsSearchViewController.hidesBottomBarWhenPushed = true
        outletsSearchViewController.viewModel = viewModel
        viewModel.refresh()
        return outletsSearchViewController
    }
}

extension OutletsSearchViewController: DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> OutletsSearchViewController? {
        return build(OutletsSearchViewModel())
    }
}

extension OutletsSearchViewController {
    static func assembleOutletsSearchViewControllerWithState(outletsSearchViewModelState: OutletsSearchViewModelState?) -> OutletsSearchViewController {
        let storyboard = UIStoryboard(name: "OutletsSearch", bundle: NSBundle.mainBundle())
        let outletsSearchViewController = storyboard.instantiateViewControllerWithIdentifier(String(OutletsSearchViewController)) as! OutletsSearchViewController
        let outletsSearchViewModel = OutletsSearchViewModel()
        if let outletsSearchViewModelState = outletsSearchViewModelState {
            outletsSearchViewModel.viewModelState.value = outletsSearchViewModelState
        }
        outletsSearchViewController.hidesBottomBarWhenPushed = true
        outletsSearchViewController.viewModel = outletsSearchViewModel
        outletsSearchViewModel.refresh()

        return outletsSearchViewController
    }
}
