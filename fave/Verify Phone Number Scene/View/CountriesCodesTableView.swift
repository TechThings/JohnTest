//
//  CountriesCodesTableView.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class CountriesCodesTableView: TableView {

    // MARK:- ViewModel
    var viewModel: CountriesCodesTableViewModel! {
        didSet { bind() }
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName:literal.CountriesCodesTableViewCell, bundle: nil), forCellReuseIdentifier: literal.CountriesCodesTableViewCell)
        rowHeight =  UITableViewAutomaticDimension
        keyboardDismissMode = .OnDrag
        estimatedRowHeight = 30
    }
}

// MARK:- ViewModelBinldable
extension CountriesCodesTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)
    }
}
