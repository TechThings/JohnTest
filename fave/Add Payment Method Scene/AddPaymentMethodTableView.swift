//
//  AddPaymentMethodTableView.swift
//  FAVE
//
//  Created by Ranjeet on 23/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class AddPaymentMethodTableView: TableView {

    // MARK:- ViewModel
    var viewModel: AddPaymentMethodTableViewModel! {
        didSet { bind() }
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName:literal.AddPaymentMethodTableViewCell, bundle: nil), forCellReuseIdentifier: literal.AddPaymentMethodTableViewCell)
        estimatedRowHeight = 512
        rowHeight =  estimatedRowHeight

//        refreshControl
//            .rx_controlEvent(UIControlEvents.ValueChanged)
//            .subscribeNext { [weak self] in
//                self?.viewModel.refresh()
//            }.addDisposableTo(disposeBag)

        // Used to stop the refreshing
//        networkActivityIndicator
//            .filter({ (active) -> Bool in !active })
//            .driveNext {[weak self] _ in
//                self?.refreshControl.endRefreshing()
//            }.addDisposableTo(disposeBag)
    }
}

// MARK:- ViewModelBinldable
extension AddPaymentMethodTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)

        activityIndicator.trackActivityIndicator(viewModel.activityIndicator)
    }
}

// MARK:- Refreshable
extension AddPaymentMethodTableView: Refreshable {
    func refresh() {
    }
}
