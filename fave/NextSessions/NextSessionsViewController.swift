//
//  NextSessionsViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 7/29/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NextSessionsViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: NextSessionsViewModel!

    // MARK:- Constant
    func registerTableViewCell() {
        self.tableView.registerNib(UINib(nibName: String(NextSessionsTimeSlotTableViewCell), bundle: nil), forCellReuseIdentifier: String(NextSessionsTimeSlotTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(NextSessionsDateHeaderView), bundle: nil), forHeaderFooterViewReuseIdentifier: String(NextSessionsDateHeaderView))
    }

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO
        self.title = NSLocalizedString("activity_detail_view_more_sessions_button_text", comment: "")
        bind()
        registerTableViewCell()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_SELECT_TIMESLOT)
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension NextSessionsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(String(NextSessionsDateHeaderView)) as! NextSessionsDateHeaderView
        header.dateLabel.text = viewModel.nextSessions.value[section].date.DiscoveryDateString!
        return header
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 10))
        footer.backgroundColor = UIColor.clearColor()
        return footer
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

extension NextSessionsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.nextSessions.value.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nextSessions.value[section].items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellItem = viewModel.nextSessions.value[indexPath.section].items[indexPath.row]
        let cellViewModel = NextSessionsTimeSlotTableViewCellViewModel(classSession: cellItem)
        let cell = tableView.dequeueReusableCellWithIdentifier(String(NextSessionsTimeSlotTableViewCell), forIndexPath: indexPath) as! NextSessionsTimeSlotTableViewCell
        cell.viewModel = cellViewModel
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.bind()

        cell
            .bookButton
            .rx_tap
            .subscribeNext { () in
            let confirmationVC = ConfirmationViewController.build(ConfirmationViewModel(listingDetails: self.viewModel.listingTimeSlotDetails, classSession: cellItem))
            self.navigationController?.presentViewController(confirmationVC, animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)

        return cell
    }
}

// MARK:- ViewModelBinldable
extension NextSessionsViewController: ViewModelBindable {
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

        viewModel.nextSessions
        .asObservable()
        .subscribeOn(MainScheduler.instance)
        .subscribeNext { [weak self] _ in
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension NextSessionsViewController: Refreshable {
    func refresh() {
        viewModel.refresh()
    }
}

// MARK:- Buildable
extension NextSessionsViewController: Buildable {
    final class func build(builder: NextSessionsViewModel) -> NextSessionsViewController {
        let storyboard = UIStoryboard(name: "NextSessions", bundle: nil)
        builder.refresh()
        let viewController = storyboard.instantiateViewControllerWithIdentifier(String(NextSessionsViewController)) as! NextSessionsViewController
        viewController.viewModel = builder
        return viewController
    }
}
