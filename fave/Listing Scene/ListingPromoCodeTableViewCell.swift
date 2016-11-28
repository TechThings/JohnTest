//
//  ListingPromoCodeTableViewCell.swift
//  FAVE
//
//  Created by Gaddafi Rusli on 18/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingPromoCodeTableViewCell: TableViewCell {

    @IBOutlet weak var descriptionLabel: KFITLabel!

    var viewModel: ListingPromoCodeTableViewCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.lineSpacing = 2.3
        descriptionLabel.textAlignment = .Left
    }
}

extension ListingPromoCodeTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.promoDescription.drive(descriptionLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
    }
}
