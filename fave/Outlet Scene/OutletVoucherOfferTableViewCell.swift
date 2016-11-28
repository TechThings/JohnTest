//
//  OutletVoucherOfferTableViewCell.swift
//  FAVE
//
//  Created by Michael Cheah on 7/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class OutletVoucherOfferTableViewCell: TableViewCell {

    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var finalPriceLabel: UILabel!

    @IBOutlet weak var originalPriceLabel: UILabel!

    // MARK:- ViewModel
    var viewModel: OutletOfferViewModel!

    // MARK:- Constants

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable

extension OutletVoucherOfferTableViewCell: ViewModelBindable {
    func bind() {
        if let featureImage = viewModel.featureImage {
            self.featuredImage.kf_setImageWithURL(
                    featureImage,
                    placeholderImage: UIImage(named: "image-placeholder"),
                    optionsInfo: [.Transition(ImageTransition.Fade(0.5))],
                    progressBlock: nil,
                    completionHandler: nil)
        } else {
            self.featuredImage.image = UIImage(named: "image-placeholder")
        }

        self.activityName.text = viewModel.activityName
        self.finalPriceLabel.text = viewModel.finalPrice

        if let originPrice = viewModel.originalPrice {
            self.originalPriceLabel.text = originPrice
        } else {
            self.originalPriceLabel.hidden = true
        }
    }
}
