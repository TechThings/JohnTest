//
//  MyFaveCurrentReservationViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MyFaveCurrentReservationViewController: ViewController, Scrollable {

    // MARK:- IBOutlet

    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: MyFaveCurrentReservationViewModel!
    var refreshControl = UIRefreshControl()

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        registerCell()
        bind()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Refresh after redeem
        refresh()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_MYFAVE_PURCHASE)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func refresh(sender: AnyObject) {
        refresh()
        // Code to refresh table view
    }

    private func configureRefreshControl() {
        tableView.addSubview(refreshControl)
        refreshControl.rx_controlEvent(UIControlEvents.ValueChanged)
            .subscribeNext { [weak self] in
                self?.viewModel.refresh()
            }.addDisposableTo(disposeBag)
    }

    private func registerCell() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        tableView.registerNib(UINib(nibName: String(MyFaveEmptyResultTableViewCell), bundle: nil), forCellReuseIdentifier: String(MyFaveEmptyResultTableViewCell))
        tableView.registerNib(UINib(nibName: String(ReservationTableViewCell), bundle: nil), forCellReuseIdentifier: String(ReservationTableViewCell))
        tableView.registerNib(UINib(nibName: String(ViewAllReservationTableViewCell), bundle: nil), forCellReuseIdentifier: String(ViewAllReservationTableViewCell))
    }

    func scrollToTop() {
        tableView.setContentOffset(CGPoint.zero, animated:true)
    }
}

extension MyFaveCurrentReservationViewController: Refreshable {
    func refresh() {
        viewModel.refresh()
        // Code to refresh table view
    }
}
extension MyFaveCurrentReservationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfPastReservations.value > 0 ? 2 : 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if viewModel.isEmptyReservations.value {
                return 1
            } else {
                return viewModel.reservations.value.count
            }
        } else {
            return 1
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            if viewModel.isEmptyReservations.value {
                let cell = tableView.dequeueReusableCellWithIdentifier(String(MyFaveEmptyResultTableViewCell), forIndexPath: indexPath) as! MyFaveEmptyResultTableViewCell
                cell.messageLabel.text = NSLocalizedString("my_fave_no_purchases", comment: "")
                cell.detailsLabel.text = NSLocalizedString("my_fave_no_purchases_instruction", comment:"")
                cell.detailsLabel.lineSpacing = 2.5
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(String(ReservationTableViewCell), forIndexPath: indexPath) as! ReservationTableViewCell
                let cellViewModel = ReservationViewModel(reservation: viewModel.reservations.value[indexPath.row])
                cell.viewModel = cellViewModel
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.bind()
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ViewAllReservationTableViewCell), forIndexPath: indexPath) as! ViewAllReservationTableViewCell
            cell.pastPurchasesTitle.text = "\(NSLocalizedString("view_past_purchases", comment: "")) (\(viewModel.numberOfPastReservations.value))"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
    }
    // TAG: Thanh
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            if viewModel.reservations.value.count == 0 {
                return 250
            } else {
                if viewModel.reservations.value[indexPath.row].reservationState == ReservationState.Confirmed {
                    return 165
                } else {
                    return 195
                }
            }
        } else {
            return 65
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let pastReservationViewController = MyFavePastReservationViewController.build(MyFavePastReservationViewModel())
            self.navigationController?.pushViewController(pastReservationViewController, animated: true)
        } else {
            if viewModel.isEmptyReservations.value {
                return
            }
            let reservation = viewModel.reservations.value[indexPath.row]
            let vc = RedemptionViewController.build(RedemptionViewModel(reservationId: reservation.id))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MyFaveCurrentReservationViewController: ViewModelBindable {
    func bind() {
        viewModel.isEmptyReservations.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }.addDisposableTo(disposeBag)

        viewModel.reservations.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }.addDisposableTo(disposeBag)

        viewModel.numberOfPastReservations.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Build
extension MyFaveCurrentReservationViewController: Buildable {
    typealias ObjectType = MyFaveCurrentReservationViewController
    typealias BuilderType = MyFaveCurrentReservationViewModel

    static func build(builder: BuilderType) -> ObjectType {
        let storyboard = UIStoryboard(name: "MyFave", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(String(MyFaveCurrentReservationViewController)) as! MyFaveCurrentReservationViewController
        viewController.viewModel = builder
        return viewController
    }
}

extension MyFaveCurrentReservationViewController: DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> MyFaveCurrentReservationViewController? {
        return build(MyFaveCurrentReservationViewModel())
    }
}
