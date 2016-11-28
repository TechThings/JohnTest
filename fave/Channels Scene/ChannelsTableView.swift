//
//  ChannelsTableView.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ChannelsTableView: TableView {

    var tableViewRefreshControl = UIRefreshControl()

    // MARK:- ViewModel
    var viewModel: ChannelsTableViewModel! {
        didSet { bind() }
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName: literal.ChannelInvitationsTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelInvitationsTableViewCell)
        registerNib(UINib(nibName: literal.ChannelsHeaderViewTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelsHeaderViewTableViewCell)

        registerNib(UINib(nibName: literal.ChannelCreditsTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelCreditsTableViewCell)

        registerNib(UINib(nibName:literal.ChannelTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelTableViewCell)
        rowHeight =  UITableViewAutomaticDimension
        estimatedRowHeight = 200
        tableFooterView = UIView(frame:CGRect.zero)
        contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 100,right: 0)

        addSubview(tableViewRefreshControl)

        tableViewRefreshControl
            .rx_controlEvent(UIControlEvents.ValueChanged)
            .subscribeNext { [weak self] in
                self?.viewModel.refresh()
            }.addDisposableTo(disposeBag)

    }
}

// MARK:- ViewModelBinldable
extension ChannelsTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)

        viewModel
            .activityIndicator
            .driveNext { [weak self] (active: Bool) in
                if active == false {
                    self?.tableViewRefreshControl.endRefreshing()
                }
            }.addDisposableTo(disposeBag)

        activityIndicator.trackActivityIndicator(viewModel.activityIndicator)
    }
}
