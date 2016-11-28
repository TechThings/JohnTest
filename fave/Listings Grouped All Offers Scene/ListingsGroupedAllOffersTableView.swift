//
//  ListingsGroupedAllOffersTableView.swift
//  FAVE
//
//  Created by Thanh KFit on 11/15/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ListingsGroupedAllOffersTableView: TableView {

    // MARK:- ViewModel
    var viewModel: ListingsGroupedAllOffersTableViewModel! {
        didSet {
            bind()
            delegate = viewModel
            viewModel.refresh()
        }
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName:literal.ListingsGroupedOfferTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingsGroupedOfferTableViewCell)
    }
}

// MARK:- ViewModelBinldable
extension ListingsGroupedAllOffersTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension ListingsGroupedAllOffersTableView: Refreshable {
    func refresh() {
    }
}
