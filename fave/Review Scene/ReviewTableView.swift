//
//  ReviewTableView.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ReviewTableView: TableView {

    var tableViewRefreshControl = UIRefreshControl()

    // MARK:- ViewModel
    var viewModel: ReviewTableViewModel! {
        didSet { bind() }
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName:literal.ListingReviewTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingReviewTableViewCell)
        rowHeight =  UITableViewAutomaticDimension
        estimatedRowHeight = 200

        self.addSubview(tableViewRefreshControl)
        tableViewRefreshControl
            .rx_controlEvent(UIControlEvents.ValueChanged)
            .subscribeNext { [weak self] in
                self?.viewModel.refresh()
            }.addDisposableTo(disposeBag)

        // Used to stop the refreshing
        activityIndicator
            .filter({ (active) -> Bool in !active })
            .driveNext {[weak self] _ in
                self?.tableViewRefreshControl.endRefreshing()
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- ViewModelBinldable
extension ReviewTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)

        activityIndicator.trackActivityIndicator(viewModel.activityIndicator)
    }
}
