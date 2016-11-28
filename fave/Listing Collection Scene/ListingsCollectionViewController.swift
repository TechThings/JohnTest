//
//  ListingsCollectionViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 14/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingsCollectionViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: ListingsCollectionViewControllerViewModel!
    var cellItems = [ListingsCollectionItem]()

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if tableView.contentOffset.y  > 200 {
            self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            self.title = viewModel.currentCollection.value?.name
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"ui-gradient"), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.title = ""
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func setup() {
        registerCell()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }

    func registerCell() {
        tableView.registerNib(UINib(nibName: String(HomeListingTableViewCell), bundle: nil), forCellReuseIdentifier: String(HomeListingTableViewCell))
        tableView.registerNib(UINib(nibName: String(ListingCollectionTableViewCell), bundle: nil), forCellReuseIdentifier: String(ListingCollectionTableViewCell))
        tableView.registerNib(UINib(nibName: String(HomeListingsCollectionsTableViewCell), bundle: nil), forCellReuseIdentifier: String(HomeListingsCollectionsTableViewCell))
    }
}

extension ListingsCollectionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellItem = cellItems[indexPath.row]
        switch cellItem.itemType {
        case .CurrentCollection:
            return UITableViewAutomaticDimension
        case .Listing:
            return HomeItemKind.Listings.cellHeight
        case .CarouselCollections:
            return HomeItemKind.ListingsCollections.cellHeight
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellItem = cellItems[indexPath.row]

        if let listing = cellItem.item as? Listing {
            let viewController = ListingViewController.build(ListingViewModel(listingId: listing.id, outletId: listing.outlet.id, functionality: Variable(ListingViewModelFunctionality.Initiate())))
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)

            // Analytics
            let analyticsModel = ListingAnalyticsModel(listing: listing)
            analyticsModel.activityClickedEvent.send()
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y  > 200 {
            self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            self.title = viewModel.currentCollection.value?.name
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"ui-gradient"), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.title = ""
        }
    }

}

extension ListingsCollectionViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellItem = cellItems[indexPath.row]

        switch cellItem.itemType {
        case .CurrentCollection:
            let collection = cellItem.item as! ListingsCollection
            let cellViewModel = ListingsCollectionHeaderViewModel(listingsCollection: collection)
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ListingCollectionTableViewCell), forIndexPath: indexPath) as! ListingCollectionTableViewCell
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        case .Listing:
            let listing = cellItem.item as! Listing
            let cellViewModel = HomeListingTableViewCellViewModel(listing: listing)
            let cell = tableView.dequeueReusableCellWithIdentifier(String(HomeListingTableViewCell), forIndexPath: indexPath) as! HomeListingTableViewCell
            cell.viewModel = cellViewModel
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.bind()
            return cell

        case .CarouselCollections:
            let items = cellItem.item as! [ListingsCollection]
            let cellViewModel = HomeListingsCollectionsTableViewCellViewModel(collections: items)
            let cell = tableView.dequeueReusableCellWithIdentifier(String(HomeListingsCollectionsTableViewCell), forIndexPath: indexPath) as! HomeListingsCollectionsTableViewCell
            cell.viewModel = cellViewModel
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self
            cell.bind()
            return cell
        }
    }
}

extension ListingsCollectionViewController: Refreshable {
    func refresh() {
        viewModel.refresh()
    }
}

// MARK:- ViewModelBinldable
extension ListingsCollectionViewController: ViewModelBindable {
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

        viewModel.collectionItems.asObservable()
            .filter({$0.count > 0})
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.cellItems = $0
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

extension ListingsCollectionViewController: OutletsSearchTableViewCellModelDelegate {
    func pushViewController(viewController: UIViewController) {
        guard let viewControllers = self.navigationController?.viewControllers,
            let previousVC = viewControllers[safe:viewControllers.count - 2] else {
                return
        }

        if previousVC is ListingsCollectionsViewController {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }

        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK:- Buildable
extension ListingsCollectionViewController: Buildable {
    final class func build(builder: ListingsCollectionViewControllerViewModel) -> ListingsCollectionViewController {
        let storyboard = UIStoryboard(name: "ListingsCollection", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(ListingsCollectionViewController)) as! ListingsCollectionViewController
        vc.viewModel = builder
        builder.refresh()
        return vc
    }
}

extension ListingsCollectionViewController : DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> ListingsCollectionViewController? {
        let urlComponents = NSURLComponents(string: deepLink)
        let urlParams = urlComponents?.queryItems

        let collectionId: Int?

        if let collection_id = urlParams?.filter({$0.name == "collection_id"}).first?.value {
            collectionId = Int(collection_id)
        } else {
            guard let params = params, collection_id = params["collection_id"] as? String else {return nil}
            collectionId = Int(collection_id)
        }

        if let collectionId = collectionId {
            return build(ListingsCollectionViewControllerViewModel(collectionId: collectionId))
        }

        return nil
    }
}
