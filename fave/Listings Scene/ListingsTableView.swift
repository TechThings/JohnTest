//
//  ListingsTableView.swift
//  FAVE
//
//  Created by Thanh KFit on 10/28/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ListingsTableView: TableView {

    let refreshController = UIRefreshControl()

    // MARK:- ViewModel
    var viewModel: ListingsTableViewModel! {
        didSet {
            delegate = viewModel
            bind()
        }
    }

    var spinner: UIActivityIndicatorView!

    override func awakeFromNib() {
        registerParicularCell()
        setupRefreshControl()
        setupFooter()
    }

    func setupRefreshControl() {
        refreshController.rx_controlEvent(UIControlEvents.ValueChanged)
            .subscribeNext { [weak self] in
                self?.viewModel.refresh()
            }.addDisposableTo(disposeBag)

        if #available(iOS 10.0, *) {
            self.refreshControl = refreshController
        } else {
            self.addSubview(refreshController)
        }
    }

    func setupFooter() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.frame = CGRectMake(0, 0, UIScreen.mainWidth, 50)
        tableFooterView = spinner
        spinner.startAnimating()
    }

    func registerParicularCell() {
        print("Thanh> Register Cell: \(viewModel.state.value.categoryType)")
        registerNib(UINib(nibName: literal.MyFaveEmptyResultTableViewCell, bundle: nil), forCellReuseIdentifier: literal.MyFaveEmptyResultTableViewCell)
        registerNib(UINib(nibName: literal.FilterPickupTableViewCell, bundle: nil), forCellReuseIdentifier: literal.FilterPickupTableViewCell)
        registerNib(UINib(nibName: literal.ListingsGroupedOutletTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingsGroupedOutletTableViewCell)
        registerNib(UINib(nibName: literal.ListingsGroupedOfferTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingsGroupedOfferTableViewCell)
        registerNib(UINib(nibName: literal.ListingsHeaderTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingsHeaderTableViewCell)
        registerNib(UINib(nibName: literal.FilterIsOffTableViewCell, bundle: nil), forCellReuseIdentifier: literal.FilterIsOffTableViewCell)
        registerNib(UINib(nibName: literal.FilterIsOnTableViewCell, bundle: nil), forCellReuseIdentifier: literal.FilterIsOnTableViewCell)
        registerNib(UINib(nibName: literal.ListingsViewAllOffersTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingsViewAllOffersTableViewCell)
    }
}

// MARK:- ViewModelBinldable
extension ListingsTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)

        viewModel
            .footerHidden
            .driveNext({ [weak self] (loadedEverything) in
                // using tableFooterView.hidden here not working when switch to Home then go back to Nearby
                if loadedEverything {
                    self?.tableFooterView = nil
                } else {
                    self?.tableFooterView = self?.spinner
                }
            })
            .addDisposableTo(disposeBag)

        viewModel
            .activityIndicator
            .drive(refreshController.rx_refreshing)
            .addDisposableTo(disposeBag)

    }
}
