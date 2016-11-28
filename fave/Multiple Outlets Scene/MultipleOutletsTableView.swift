//
//  MultipleOutletsTableView.swift
//  FAVE
//
//  Created by Thanh KFit on 10/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MultipleOutletsTableView: TableView {

    // MARK:- ViewModel
    var viewModel: MultipleOutletsTableViewModel! {
        didSet {
            bind()
            self.delegate = viewModel
        }
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName:literal.MultipleOutletsOutletTableViewCell, bundle: nil), forCellReuseIdentifier: literal.MultipleOutletsOutletTableViewCell)

        registerNib(UINib(nibName:literal.MultipleOutletsOfferTableViewCell, bundle: nil), forCellReuseIdentifier: literal.MultipleOutletsOfferTableViewCell)

//        rowHeight =  UITableViewAutomaticDimension
//        estimatedRowHeight = 100
    }
}

// MARK:- ViewModelBinldable
extension MultipleOutletsTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension MultipleOutletsTableView: Refreshable {
    func refresh() {
    }
}
