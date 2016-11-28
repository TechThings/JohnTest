//
//  ListingsCollectionTableView.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxDataSources

final class ListingsCollectionsTableView: TableView {

    var tableViewRefreshControl = UIRefreshControl()

    // MARK:- ViewModel
    var viewModel: ListingsCollectionsTableViewModel! {
        didSet { bind() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName:String(ListingsCollectionViewTableViewCell), bundle: nil), forCellReuseIdentifier: String(ListingsCollectionViewTableViewCell))
        rowHeight = 181
        addSubview(tableViewRefreshControl)
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

extension ListingsCollectionsTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)

        activityIndicator.trackActivityIndicator(viewModel.activityIndicator)
    }
}

extension ListingsCollectionsTableView: Refreshable {
    func refresh() {
    }
}
