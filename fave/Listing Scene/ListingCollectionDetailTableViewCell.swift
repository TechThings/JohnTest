//
//  ListingCollectionDetailTableViewCell.swift
//  FAVE
//
//  Created by Gaddafi Rusli on 18/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingCollectionDetailTableViewCell: TableViewCell {

    @IBOutlet weak var collectionNameLabel: UILabel!

    var viewModel: ListingCollectionDetailTableViewCellViewModel!
}

extension ListingCollectionDetailTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.collectionName.drive(collectionNameLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
    }
}
