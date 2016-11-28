//
//  HomeFeaturedOfferTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeFeaturedOfferTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: HomeFeaturedOfferTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var outletLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var officialPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: KFITLabel!
    @IBOutlet weak var featuredLabel: UILabel!
    @IBOutlet weak var featuredView: UIView!
    @IBOutlet weak var gradientView: UIView!

    // MARK:- IBAction
    @IBAction func openOfferButtonDidTap(sender: AnyObject) {
        viewModel.openOfferButtonDidTap.onNext(())

    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
        featuredView.layer.cornerRadius = 3

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, UIScreen.mainScreen().width, 160)
        let topColor = UIColor(white: 0, alpha: 0).CGColor
        let bottomColor = UIColor(white: 0, alpha: 0.74).CGColor
        gradient.colors = [topColor, bottomColor]
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
    }
}

// MARK:- ViewModelBinldable
extension HomeFeaturedOfferTableViewCell: ViewModelBindable {
    func bind() {

        viewModel
            .title
            .asDriver()
            .drive(titleLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .companyName.asDriver()
            .drive(companyLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .outletName.asDriver()
            .drive(outletLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .originalPrice.asDriver()
            .drive(originalPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .officialPrice
            .asDriver()
            .drive(officialPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .featuredText
            .asDriver()
            .driveNext { [weak self](text) in
                if text.isEmpty {
                    self?.featuredView.hidden = true
                } else {
                    self?.featuredView.hidden = false
                    self?.featuredLabel.text = text.uppercaseString
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .activityImage
            .asDriver()
            .driveNext { [weak self]
                (value) in
                if let value = value {
                    self?.contentImage.kf_setImageWithURL(
                        value,
                        placeholderImage: UIImage(named: "image-placeholder"),
                        optionsInfo: [.Transition(ImageTransition.Fade(0.5))],
                        progressBlock: nil,
                        completionHandler: nil)
                } else {
                    self?.contentImage.image = UIImage(named: "image-placeholder")
                }
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}
