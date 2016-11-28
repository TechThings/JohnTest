////
////  HomeViewController.swift
////  FAVE
////
////  Created by Thanh KFit on 7/2/16.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//import UIKit
//import RxSwift
//import RxCocoa
//
//class HomeViewController: ViewController {
//    
//    // MARK:- IBOutlet
//    @IBOutlet weak var tableView: UITableView!
//    
//    // MARK:- ViewModel
//    var viewModel: HomeViewModel!
//    
//    let indexOffSetToStartLoadingAt: Int = 10
//
//    // MARK:- Variables
//    var homeItems = [HomeItem]()
//    var spinner: UIActivityIndicatorView!
//    var refreshControl: UIRefreshControl!
//
//    // MARK:- Life cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setup()
//        bind()
//        configureRefreshControl()
//        refresh()
//    }
//
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        viewModel.popWriteReviewVC()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true
//        
//    }
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated) 
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        if viewModel.needsRefresh {
//            viewModel.refresh()
//            viewModel.needsRefresh = false
//        }
//    }
//
//    func setup() {
//        registerCell()
//        configureSpinner()
//    }
//    
//    private func configureRefreshControl() {
//        refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
//        tableView.addSubview(refreshControl)
//    }
//    
//    func refresh(sender:AnyObject) {
//        viewModel.refresh()
//    }
//    
//    func registerCell() {
//        tableView.registerNib(UINib(nibName: String(HomeSearchTableViewCell), bundle: nil), forCellReuseIdentifier: String(HomeSearchTableViewCell))
//        tableView.registerNib(UINib(nibName: String(HomeFiltersTableViewCell), bundle: nil), forCellReuseIdentifier: String(HomeFiltersTableViewCell))
//        tableView.registerNib(UINib(nibName: String(HomeListingsCollectionsTableViewCell), bundle: nil), forCellReuseIdentifier: String(HomeListingsCollectionsTableViewCell))
//        tableView.registerNib(UINib(nibName: String(HomeOutletsTableViewCell), bundle: nil), forCellReuseIdentifier: String(HomeOutletsTableViewCell))
//        tableView.registerNib(UINib(nibName: String(HomeListingTableViewCell), bundle: nil), forCellReuseIdentifier: String(HomeListingTableViewCell))
//    }
//    
//    // CC: A hack to dequeueReusableCellWithIdentifier the outlets before sccrolling to it
    var token: Int = 0
    func casheHomeOutletsTableViewCell() {
        let itemIndex = self.homeItems.enumerate().filter { $1.itemType == HomeItemKind.Outlets }.first
        if let outlets = itemIndex?.element.item as? [Outlet], let index = itemIndex?.index {
            let viewModel = HomeOutletsTableViewCellViewModel(outlets: outlets, outletSearchDelegate: self)
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            let homeOutletsTableViewCell = tableView.dequeueReusableCellWithIdentifier(String(HomeOutletsTableViewCell), forIndexPath: indexPath) as! HomeOutletsTableViewCell
            homeOutletsTableViewCell.layoutIfNeeded()
            homeOutletsTableViewCell.viewModel = viewModel
            homeOutletsTableViewCell.selectionStyle = UITableViewCellSelectionStyle.None
            homeOutletsTableViewCell.delegate = self
            homeOutletsTableViewCell.bind()
        }
    }
//}
//
//extension HomeViewController: HomeGoToSearchOutletDelegate {
//    func goToSearchOutletPage() {
//        let vc = OutletsSearchViewController.build(OutletsSearchViewModel())
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension HomeViewController: OutletsSearchTableViewCellModelDelegate {
//    func pushViewController(viewController: UIViewController) {
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }
//}
//
//extension HomeViewController: UITableViewDelegate {
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let model = homeItems[indexPath.row]
//        return model.itemType.cellHeight
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let model = homeItems[indexPath.row]
//        if model.itemType == HomeItemKind.Listings {
//            let item = model.item as! Listing
//            let viewController = ListingViewController.build(ListingViewModel(listingId: item.id))
//            viewController.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(viewController, animated: true)
//
//            // Analytics
//            let analyticsModel = ListingAnalyticsModel(listing: item)
//            analyticsModel.activityClickedEvent.send()
//        }
//    }
//    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if homeItems.count - indexPath.row == indexOffSetToStartLoadingAt {
//            viewModel.loadNextPage()
//        }
//    }
//    
//    private func configureSpinner() {
//        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//        spinner.frame = CGRectMake(0, 0, tableView.frame.size.width, 50)
//        tableView.tableFooterView = spinner
//        
//        networkActivityIndicator
//            .drive(spinner.rx_animating)
//            .addDisposableTo(disposeBag)
//    }
//}
//
//extension HomeViewController: UITableViewDataSource {
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return homeItems.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let model = homeItems[indexPath.row]
//        
//        switch model.itemType {
//        case .Search:
//
//            let cellViewModel = HomeSearchTableViewCellViewModel.init()
//            let cell = tableView.dequeueReusableCellWithIdentifier(String(HomeSearchTableViewCell), forIndexPath: indexPath) as! HomeSearchTableViewCell
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            cell.viewModel = cellViewModel
//            cell.bind()
//            cell.delegate = self
//
//            return cell
//            
//        case .Filter:
//            let item = model.item as! [FaveFilter]
//            let cellViewModel = HomeFiltersTableCellViewModel(filters: item)
//            let cell = tableView.dequeueReusableCellWithIdentifier(String(HomeFiltersTableViewCell), forIndexPath: indexPath) as! HomeFiltersTableViewCell
//            cell.viewModel = cellViewModel
//            cell.delegate = self
//            cell.bind()
//            
//            if let outlets = homeItems.filter({ homeItem -> Bool in return homeItem.itemType == HomeItemKind.Outlets}).first?.item as? [Outlet] where outlets.count > 0 {
//                dispatch_once(&token) { () -> Void in
//                    self.casheHomeOutletsTableViewCell()
//                }
//            }
//
//            return cell
//            
//        case .Listings:
//            let item = model.item as! Listing
//            let cellViewModel = HomeListingTableViewCellViewModel(listing: item, index: indexPath.row)
//            let cell = tableView.dequeueReusableCellWithIdentifier(String(HomeListingTableViewCell), forIndexPath: indexPath) as! HomeListingTableViewCell
//            cell.viewModel = cellViewModel
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            cell.bind()
//            return cell
//            
//        case .Outlets:
//            let items = model.item as! [Outlet]
//            let viewModel = HomeOutletsTableViewCellViewModel(outlets: items, outletSearchDelegate: self)
//            let cell = tableView.dequeueReusableCellWithIdentifier(String(HomeOutletsTableViewCell), forIndexPath: indexPath) as! HomeOutletsTableViewCell
//            cell.viewModel = viewModel
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            cell.delegate = self
//            cell.bind()
//            return cell
//            
//        case .ListingsCollections:
//            let items = model.item as! [ListingsCollection]
//            let cellViewModel = HomeListingsCollectionsTableViewCellViewModel.init(collections: items)
//            let cell = tableView.dequeueReusableCellWithIdentifier(String(HomeListingsCollectionsTableViewCell), forIndexPath: indexPath) as! HomeListingsCollectionsTableViewCell
//            cell.viewModel = cellViewModel
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            cell.delegate = self
//            cell.bind()
//            return cell
//        }
//    }
//}
//
extension HomeViewController: HomeFiltersTableViewCellDelegate {
    func didTapFilter(filter: FaveFilter) {
        let filterViewModel = FilterViewModel(categoryType: filter.type.rawValue)
        let filterViewController = FilterViewController.build(filterViewModel)
        filterViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(filterViewController, animated: true)
    }
}
//
//// MARK:- ViewModelBinldable
//extension HomeViewController: ViewModelBindable {
//    func bind() {
//        viewModel.homeItems
//            .asObservable()
//            .subscribeOn(MainScheduler.instance)
//            .subscribeNext { [weak self] in
//                guard let strongSelf = self else {return}
//                strongSelf.homeItems = $0
//                strongSelf.tableView.reloadData()
//                strongSelf.refreshControl.endRefreshing()
//            }.addDisposableTo(disposeBag)
//        
//        viewModel.writeReviewVC
//            .asDriver()
//            .filterNil()
//            .driveNext { [weak self] (vc) in
//                self?.presentViewController(vc, animated: true, completion: nil)
//            }.addDisposableTo(disposeBag)
//    }
//}
//
//// MARK:- Refreshable
//extension HomeViewController: Refreshable {
//    func refresh() {
//        viewModel.refresh()
//    }
//}
//
//// MARK:- Build
//extension HomeViewController: Buildable {
//    class func build(builder: HomeViewModel) -> HomeViewController {
//        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//        let homeViewModel = HomeViewModel()
//        let homeViewController = storyboard.instantiateViewControllerWithIdentifier(String(HomeViewController)) as! HomeViewController
//        homeViewController.viewModel = homeViewModel
//        return homeViewController
//    }
//}
//
//extension HomeViewController: DeepLinkBuildable {
//    static func build(deepLink: String, params: [String : AnyObject]?) -> HomeViewController? {
//        return build(HomeViewModel())
//    }
//}
