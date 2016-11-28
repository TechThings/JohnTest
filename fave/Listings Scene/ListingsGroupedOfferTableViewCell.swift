//
//  ListingsGroupedOfferTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 10/28/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ListingsGroupedOfferTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ListingsGroupedOfferTableViewCellViewModel! {
        didSet { bind() }
    }

    @IBOutlet weak var listingNameLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: KFITLabel!
    @IBOutlet weak var officialPriceLabel: UILabel!
    @IBOutlet weak var listingImageView: UIImageView!
}

extension ListingsGroupedOfferTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .activityName
            .asDriver()
            .drive(listingNameLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .originalPrice
            .asDriver()
            .drive(originalPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .officialPrice
            .asDriver()
            .drive(officialPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .activityImage
            .asDriver()
            .filterNil()
            .driveNext({ [weak self] (url: NSURL) in
                self?.listingImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "image-placeholder"), optionsInfo: [.Transition(ImageTransition.Fade(0.5))], progressBlock: nil, completionHandler: nil)
            })
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
