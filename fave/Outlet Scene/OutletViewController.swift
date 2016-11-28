//
//  OutletViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OutletViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: OutletViewControllerViewModel!

    // MARK- Output
    var outletItems = [Int: [OutletItem]]()

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if tableView.contentOffset.y  > 150 {
            self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            self.title = (viewModel.company?.name).emptyOnNil()
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

        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_PARTNER_DETAIL)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
    }

    func setup() {
        registerTableCells()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }

    func registerTableCells() {
        self.tableView.registerNib(UINib(nibName: String(CompanyDetailsTableViewCell), bundle: nil), forCellReuseIdentifier: String(CompanyDetailsTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(OutletLocationTableViewCell), bundle: nil), forCellReuseIdentifier: String(OutletLocationTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(OutletVoucherOfferTableViewCell), bundle: nil), forCellReuseIdentifier: String(OutletVoucherOfferTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(OutletTimeslotOfferTableViewCell), bundle: nil), forCellReuseIdentifier: String(OutletTimeslotOfferTableViewCell))
        self.tableView.registerNib(UINib(nibName: "OutletViewSeparator", bundle: nil), forCellReuseIdentifier: "OutletViewSeparator")

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
    }

    func goToOffersDetail(listing: ListingType) {
        let viewController = ListingViewController.build(ListingViewModel(listingId: listing.id, outletId: listing.outlet.id, functionality: Variable(ListingViewModelFunctionality.Initiate())))
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)

        // Analytics
        let analyticsModel = ListingAnalyticsModel(listing: listing)
        analyticsModel.activityClickedEvent.send()
    }
}

extension OutletViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let sectionItems = self.outletItems[indexPath.section]
        let model = sectionItems![indexPath.row]

        switch model.itemType {
        case .Separator:
            return 10
        case .VoucherListing:
            return 107
        case .TimeslotListing:
            return 107
        case .LocationHeader, .OffersHeader:
            return 50
        default:
            return UITableViewAutomaticDimension
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionItems = self.outletItems[indexPath.section]
        let model = sectionItems![indexPath.row]

        switch model.itemType {
        case .VoucherListing:

            let cellViewModel = model.item as! OutletOfferViewModel
            self.goToOffersDetail(cellViewModel.listing)

            return
        case .TimeslotListing:
            let cellViewModel = model.item as! OutletOfferViewModel
            self.goToOffersDetail(cellViewModel.listing)

            return
        default:
            // Do Nothing
            return
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y  > 150 {
            self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            self.title = (viewModel.company?.name).emptyOnNil()
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"ui-gradient"), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.title = ""
        }
    }

}

extension OutletViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if viewModel.company.value == nil || viewModel.outlet.value == nil {return 0}
        return self.outletItems.keys.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRowsInSection = self.outletItems[section]?.count else { return 0}
        return numberOfRowsInSection
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionItems = self.outletItems[indexPath.section]
        let model = sectionItems![indexPath.row]

        switch model.itemType {
        case .Header:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(CompanyDetailsTableViewCell), forIndexPath: indexPath) as! CompanyDetailsTableViewCell
            let cellViewModel = CompanyDetailsViewModel(outlet: viewModel.outlet!, company: viewModel.company!)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell
        case .Location:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(OutletLocationTableViewCell), forIndexPath: indexPath) as! OutletLocationTableViewCell
            let cellViewModel = OutletContactViewModel(outlet: viewModel.outlet!)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell
        case .VoucherListing:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(OutletVoucherOfferTableViewCell), forIndexPath: indexPath) as! OutletVoucherOfferTableViewCell
            let cellViewModel = model.item as! OutletOfferViewModel
            cell.viewModel = cellViewModel
            cell.bind()

            return cell
        case .TimeslotListing:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(OutletTimeslotOfferTableViewCell), forIndexPath: indexPath) as! OutletTimeslotOfferTableViewCell
            let cellViewModel = model.item as! OutletOfferViewModel
            cell.viewModel = cellViewModel
            cell.bind()

            return cell
        case .Separator:
            let cell = tableView.dequeueReusableCellWithIdentifier("OutletViewSeparator", forIndexPath: indexPath)
            return cell

        case .OffersHeader:
            let cell = tableView.dequeueReusableCellWithIdentifier("OutletOffersHeader", forIndexPath: indexPath)
            return cell

        case .LocationHeader:
            let cell = tableView.dequeueReusableCellWithIdentifier("OutletLocationHeader", forIndexPath: indexPath)
            return cell
        }
    }
}

// MARK:- ViewModelBinldable

extension OutletViewController: ViewModelBindable {
    func bind() {
        viewModel.outletItems
            .asDriver()
            .filterEmpty()
            .driveNext {
                [weak self] in
                self?.outletItems = $0
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable

extension OutletViewController: Buildable {
    final class func build(builder: OutletViewControllerViewModel) -> OutletViewController {
        let storyboard = UIStoryboard(name: "Outlet", bundle: nil)
        let outletViewController = storyboard.instantiateViewControllerWithIdentifier(String(OutletViewController)) as! OutletViewController
        outletViewController.viewModel = builder
        return outletViewController
    }
}

extension OutletViewController : DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> OutletViewController? {
        let urlComponents = NSURLComponents(string: deepLink)
        let urlParams = urlComponents?.queryItems

        let outletId: Int?
        let companyId: Int?

        if let outlet_id = urlParams?.filter({$0.name == "outlet_id"}).first?.value, let company_id = urlParams?.filter({$0.name == "company_id"}).first?.value {
            outletId = Int(outlet_id)
            companyId = Int(company_id)
        } else {
            guard let params = params, let outlet_id = params["outlet_id"] as? String, let company_id = params["company_id"] as? String else {return nil}
            outletId = Int(outlet_id)
            companyId = Int(company_id)
        }

        if let outletId = outletId, let companyId = companyId {
            return build(OutletViewControllerViewModel(outletId: outletId, companyId: companyId))
        }

        return nil
    }
}
