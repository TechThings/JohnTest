//
//  MyFavePastReservationViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MyFavePastReservationViewController: ViewController {

    // MARK:- IBOutlet

    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: MyFavePastReservationViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.translucent = true
    }

    func setup() {
        tableView.registerNib(UINib(nibName: String(ReservationTableViewCell), bundle: nil), forCellReuseIdentifier: String(ReservationTableViewCell))
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
}

extension MyFavePastReservationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reservations.value.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(ReservationTableViewCell), forIndexPath: indexPath) as! ReservationTableViewCell
        let cellViewModel = ReservationViewModel(reservation: viewModel.reservations.value[indexPath.row])
        cell.viewModel = cellViewModel
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.bind()
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 200 : 64
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let reservation = viewModel.reservations.value[indexPath.row]
        let vc = RedemptionViewController.build(RedemptionViewModel(reservationId: reservation.id))
        self.navigationController?.pushViewController(vc, animated: true)

    }
}

extension MyFavePastReservationViewController: ViewModelBindable {
    func bind() {
        viewModel.reservations
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Build
extension MyFavePastReservationViewController: Buildable {

    static func build(builder: MyFavePastReservationViewModel) -> MyFavePastReservationViewController {
        let storyboard = UIStoryboard(name: "MyFave", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(String(MyFavePastReservationViewController)) as! MyFavePastReservationViewController
        viewController.viewModel = builder
        builder.refresh()
        return viewController
    }
}
