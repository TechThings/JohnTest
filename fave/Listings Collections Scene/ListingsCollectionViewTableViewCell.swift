//
//  ListingsCollectionViewTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ListingsCollectionViewTableViewCell: TableViewCell {

    // MARK:- @IBOutlet
    @IBOutlet weak var listingsCollectionView: ListingsCollectionView!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
