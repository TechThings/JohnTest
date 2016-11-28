//
//  ListingsViewAllOffersTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 10/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingsViewAllOffersTableViewCell: TableViewCell {

    var viewModel: ListingsViewAllOffersTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

}

extension ListingsViewAllOffersTableViewCell: ViewModelBindable {
    func bind() {

    }
}
