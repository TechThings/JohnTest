//
//  HomeTableView.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class HomeTableView: TableView {

    // MARK:- ViewModel
    var viewModel: HomeTableViewModel! {
        didSet {
            bind()
            self.delegate = viewModel
        }
    }
    let tableViewRefreshControl = UIRefreshControl()

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName:literal.HomeInviteFriendTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeInviteFriendTableViewCell)
        registerNib(UINib(nibName:literal.HomeFeaturedOfferTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeFeaturedOfferTableViewCell)
        registerNib(UINib(nibName:literal.HomeListingTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeListingTableViewCell)
        registerNib(UINib(nibName:literal.HomeHeaderTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeHeaderTableViewCell)
        registerNib(UINib(nibName:literal.HomeFiltersTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeFiltersTableViewCell)
        registerNib(UINib(nibName:literal.HomePartnersCarouselTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomePartnersCarouselTableViewCell)
        registerNib(UINib(nibName:literal.HomeCollectionsCarouselTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeCollectionsCarouselTableViewCell)
        registerNib(UINib(nibName:literal.HomeOffersCarouselTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeOffersCarouselTableViewCell)
        registerNib(UINib(nibName:literal.HomeOffersCarouselTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeOffersCarouselTableViewCell)
        registerNib(UINib(nibName:literal.HomeFaveInformationTableViewCell, bundle: nil), forCellReuseIdentifier: literal.HomeFaveInformationTableViewCell)

        configureSpinner()
    }

    override func awakeFromNib() {
        tableViewRefreshControl
            .addTarget(self, action: #selector(HomeTableView.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.addSubview(tableViewRefreshControl)
    }

    private func configureSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.frame = CGRectMake(0, 0, self.frame.size.width, 50)
        tableFooterView = spinner

        viewModel.activityIndicator
            .drive(spinner.rx_animating)
            .addDisposableTo(disposeBag)
    }
}

// MARK:- ViewModelBinldable
extension HomeTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .filterEmpty()
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension HomeTableView: Refreshable {
    func refresh() {
        viewModel.refresh()
        tableViewRefreshControl.endRefreshing()
    }
}
