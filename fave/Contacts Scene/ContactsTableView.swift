//
//  ContactsTableView.swift
//  FAVE
//
//  Created by Nazih Shoura on 09/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ContactsTableView: TableView {

    // MARK:- ViewModel
    var viewModel: ContactsTableViewModel! {
        didSet { bind() }
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        registerNib(UINib(nibName:literal.ContactViewTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ContactViewTableViewCell)
        registerNib(UINib(nibName:literal.FaveContactHeaderTableViewCell, bundle: nil), forCellReuseIdentifier: literal.FaveContactHeaderTableViewCell)
        registerNib(UINib(nibName:literal.NonFaveContactHeaderTableViewCell, bundle: nil), forCellReuseIdentifier: literal.NonFaveContactHeaderTableViewCell)
        separatorStyle = .None
        keyboardDismissMode = .OnDrag
        rowHeight =  UITableViewAutomaticDimension
        estimatedRowHeight = 200

    }
}

// MARK:- ViewModelBinldable
extension ContactsTableView: ViewModelBindable {
    func bind() {
        viewModel
            .sectionsModels
            .asDriver()
            .drive(self.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(disposeBag)
    }
}

extension ContactsTableView: Resettable {
    @objc
    func reset() {
        viewModel.reset()
    }
}
