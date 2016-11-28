//
//  RedemptionViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

enum ConfirmRedeemAction {
    case Cancel
    case Redeem
    case None
}

final class RedemptionViewController: ViewController {

    // MARK:- IBOutlet variable
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var redeemMultipleOutlet: RedeemMultipleOutletView!
    @IBOutlet weak var redeemMultipleOutletHeight: NSLayoutConstraint!
    @IBOutlet weak var redeemMultipleOutletWidth: NSLayoutConstraint!

    @IBOutlet weak var opacityView: UIView!
    // MARK:- ViewModel
    var viewModel: RedemptionViewModel!
    let redeemMultipleOutletViewModel = RedeemMultipleOutletViewModel()

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureRedeemMultipleOutletView()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setNeedsLayout()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_REDEMPTION)
        viewModel.setAsActive()

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func configureTableView() {
        tableView.registerNib(UINib(nibName: String(PendingPaymentReservationViewCell), bundle: nil), forCellReuseIdentifier: String(PendingPaymentReservationViewCell))

        tableView.registerNib(UINib(nibName: String(ProcessingPaymentReservationViewCell), bundle: nil), forCellReuseIdentifier: String(ProcessingPaymentReservationViewCell))

        tableView.registerNib(UINib(nibName: String(RedeemableReservationViewCell), bundle: nil), forCellReuseIdentifier: String(RedeemableReservationViewCell))
        tableView.registerNib(UINib(nibName: String(CancelReservationViewCell), bundle: nil), forCellReuseIdentifier: String(CancelReservationViewCell))
        tableView.registerNib(UINib(nibName: String(ListingOutletViewCell), bundle: nil), forCellReuseIdentifier: String(ListingOutletViewCell))
        tableView.registerNib(UINib(nibName: String(ReservationTimeSlotDetailsViewCell), bundle: nil), forCellReuseIdentifier: String(ReservationTimeSlotDetailsViewCell))
        tableView.registerNib(UINib(nibName: String(OutletContactViewCell), bundle: nil), forCellReuseIdentifier: String(OutletContactViewCell))
        tableView.registerNib(UINib(nibName: String(RedeemedReservationViewCell), bundle: nil), forCellReuseIdentifier: String(RedeemedReservationViewCell))
        tableView.registerNib(UINib(nibName: literal.RedemptionThingsToKnowTableViewCell, bundle: nil), forCellReuseIdentifier: literal.RedemptionThingsToKnowTableViewCell)
        tableView.registerNib(UINib(nibName: literal.CanceledReservationViewCell, bundle: nil), forCellReuseIdentifier: literal.CanceledReservationViewCell)
        tableView.registerNib(UINib(nibName: literal.ViewAllMultipleOutletsTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ViewAllMultipleOutletsTableViewCell)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 600

        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 20,right: 0)
        tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections)), withRowAnimation: .None)

    }

    func configureRedeemMultipleOutletView() {
        redeemMultipleOutlet.viewModel = redeemMultipleOutletViewModel
        hideRedeemMultipleOutletView(ConfirmRedeemAction.None)
    }

    func hideRedeemMultipleOutletView(action: ConfirmRedeemAction) {
        redeemMultipleOutletWidth.constant = UIScreen.mainWidth * 0.95
        redeemMultipleOutletHeight.constant = UIScreen.mainHeight * 0.95
        let tscale = CGAffineTransformMakeScale(0.8, 0.8)
        let tmove = CGAffineTransformMakeTranslation(0,30)
        UIView.animateWithDuration(0.15, animations: {
            self.redeemMultipleOutlet.alpha = 0
            self.opacityView.alpha = 0
            self.redeemMultipleOutlet.transform = CGAffineTransformConcat(tscale, tmove)
            }) { (completed) in
                self.opacityView.hidden = true
                self.redeemMultipleOutlet.hidden = true
                switch action {
                case ConfirmRedeemAction.Cancel:
                        self.viewModel.redeemCancelDidTap.onNext()
                case ConfirmRedeemAction.Redeem:
                    self.viewModel.redeemConfirmedDidTap.onNext()
                default:
                    break
                }
        }
    }

    func showRedeemMultipleOutletView() {
        opacityView.hidden = false
        redeemMultipleOutlet.hidden = false
        redeemMultipleOutlet.alpha = 0
        let tscale = CGAffineTransformMakeScale(1, 1)
        let tmove = CGAffineTransformMakeTranslation(0, 0)
        UIView.animateWithDuration(0.2, animations: {
            self.redeemMultipleOutlet.alpha = 1
            self.opacityView.alpha = 1
            self.redeemMultipleOutlet.transform = CGAffineTransformConcat(tscale, tmove)
        })
    }
}

extension RedemptionViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.redeemItemsKind.value.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let redeemItemKind = viewModel.redeemItemsKind.value[indexPath.row]

        switch redeemItemKind {
        case .PendingPaymentReservationView:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(PendingPaymentReservationViewCell), forIndexPath: indexPath) as! PendingPaymentReservationViewCell
            cell.pendingPaymentReservationView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind) as! PendingPaymentReservationViewModel
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell

        case .ProcessingPaymentReservationView:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ProcessingPaymentReservationViewCell), forIndexPath: indexPath) as! ProcessingPaymentReservationViewCell
            cell.processingPaymentReservationView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind) as! ProcessingPaymentReservationViewModel
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell

        case .RedeemableReservationView:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(RedeemableReservationViewCell), forIndexPath: indexPath) as! RedeemableReservationViewCell
            cell.redeemableReservationView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind) as! RedeemableReservationViewModel
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        case .CancelReservationView:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(CancelReservationViewCell), forIndexPath: indexPath) as! CancelReservationViewCell
            cell.cancelReservationView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind) as! CancelReservationViewModel
            cell.cancelReservationView.bind()
            return cell

        case .ListingOutletView:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ListingOutletViewCell), forIndexPath: indexPath) as! ListingOutletViewCell
            cell.listingOutletView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind)  as! ListingOutletViewModel
            cell.listingOutletView.bind()

            return cell

        case .ReservationTimeSlotDetailsView:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ReservationTimeSlotDetailsViewCell), forIndexPath: indexPath) as! ReservationTimeSlotDetailsViewCell
            cell.reservationTimeSlotDetailsView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind)  as! ReservationTimeSlotDetailsViewModel
            cell.reservationTimeSlotDetailsView.bind()
            return cell

        case .OutletContactView:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(OutletContactViewCell), forIndexPath: indexPath) as! OutletContactViewCell
            cell.outletContactView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind)  as! OutletContactViewModel
            cell.outletContactView.bind()
            return cell

        case .ViewAllMultipleOutletsView:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ViewAllMultipleOutletsTableViewCell, forIndexPath: indexPath) as! ViewAllMultipleOutletsTableViewCell
            cell.viewAllMultipleOutletsView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind)  as! ViewAllMultipleOutletsViewModel
            return cell

        case .RedeemedReservationView:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(RedeemedReservationViewCell), forIndexPath: indexPath) as! RedeemedReservationViewCell
            cell.redeemedReservationView.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind)  as! RedeemedReservationViewModel
            cell.redeemedReservationView.bind()

            return cell

        case .ThingsToKnow:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.RedemptionThingsToKnowTableViewCell, forIndexPath: indexPath) as! ListingThingsToKnowTableViewCell
            cell.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind)  as! ListingThingsToKnowTableViewCellViewModel
            cell.bind()
            return cell

        case .CanceledReservationView:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.CanceledReservationViewCell, forIndexPath: indexPath) as! CanceledReservationViewCell
            cell.viewModel = viewModel.viewModel(forRedemptionItemKind: redeemItemKind) as! CanceledReservationViewCellViewModel
            cell.bind()
            return cell
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y  > 300 {
            self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            self.title = NSLocalizedString("purchase_detail_title_text", comment: "").capitalizedString
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.title = ""
        }
    }

}

extension RedemptionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let redeemItemKind = viewModel.redeemItemsKind.value[indexPath.row]

        switch redeemItemKind {

        case .RedeemableReservationView:
            return viewModel.redeemableReservationRowHeight.value

        case .OutletContactView:
            return 84

        case .ViewAllMultipleOutletsView:
            if let totalRedeemableOutlets = viewModel.reservation.value?.listingDetails.totalRedeemableOutlets where totalRedeemableOutlets > 1 {
                return 84
            }
            return CGFloat.min

        case .ThingsToKnow:
            return viewModel.activityThingsToKnowRowHeight.value + 60
        default:
            return UITableViewAutomaticDimension
        }

    }
}
// MARK:- Build
extension RedemptionViewController: Buildable {
    final class func build(buider: RedemptionViewModel) -> RedemptionViewController {
        let storyboard = UIStoryboard(name: "Redemption", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(RedemptionViewController)) as! RedemptionViewController
        vc.viewModel = buider
        return vc
    }
}

// MARK:- ViewModelBinldable
extension RedemptionViewController: ViewModelBindable {
    func bind() {

        viewModel
            .reservation
            .asObservable()
            .filterNil()
            .map { (reservation) -> Int in
                reservation.listingDetails.id
            }.bindTo(redeemMultipleOutletViewModel.listingId)
            .addDisposableTo(disposeBag)

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
            .redeemItemsKind.asDriver()
            .driveNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        viewModel
            .redeemableReservationRowHeight
            .asObservable()
            .filter { (cellHeight) -> Bool in
                return cellHeight > 0
            }.take(1)
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                // CC: Need reload RedeemableReservation only
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        viewModel
            .activityThingsToKnowRowHeight
            .asObservable()
            .filter {
                return $0 > 0
            }
            .take(1) // Otherwise we will have infinite loop
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                // CC: Need reload ThingsToKnow only
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        viewModel
            .openOutlet
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (outlet, company) in
                let vc = OutletViewController.build(OutletViewControllerViewModel(outletId: outlet.id, companyId: company.id))
                self?.navigationController?.pushViewController(vc, animated: true)
            }.addDisposableTo(disposeBag)

        redeemMultipleOutletViewModel
            .cancelButtonDidTap
            .asDriver(onErrorJustReturn: ())
            .driveNext { [weak self] () in
                self?.hideRedeemMultipleOutletView(ConfirmRedeemAction.Cancel)
            }.addDisposableTo(disposeBag)

        redeemMultipleOutletViewModel
            .redeemButtonDidTap
            .subscribeNext({ [weak self] () in
                self?.hideRedeemMultipleOutletView(ConfirmRedeemAction.Redeem)
            })
            .addDisposableTo(disposeBag)

        redeemMultipleOutletViewModel
            .selectedOutletId
            .asObservable()
            .bindTo(viewModel.selectedOutletId)
            .addDisposableTo(disposeBag)

        viewModel
            .redeemShowConfirm
            .subscribeNext { [weak self] () in
                self?.showRedeemMultipleOutletView()
            }
            .addDisposableTo(disposeBag)

    }
}
