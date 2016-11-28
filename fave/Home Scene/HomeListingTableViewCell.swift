//
//  HomeActivitesTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeListingTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: HomeListingTableViewCellViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalOutletLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var officialPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: KFITLabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var faveRatingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var faveRatingView: UIView!
    @IBOutlet weak var faveDistanceView: UIView!
    @IBOutlet weak var distanceWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var officialPriceWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var companyLabel: UILabel!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        originalPriceLabel.strikeThrough = true
        setup()
    }

    override func prepareForReuse() {
        faveRatingView.hidden = false
    }

    @IBAction func didTapFaveButton(sender: AnyObject) {
        if viewModel.favoritedId.value > 0 {
            let image = UIImage(named: "ic_outlet_favourited_white")
            favouriteButton.setImage(image, forState: UIControlState.Normal)
            viewModel.deleteFavoriteOutlet()
        } else {
            let image = UIImage(named: "ic_outlet_favourited_fill")
            favouriteButton.setImage(image, forState: UIControlState.Normal)
            viewModel.didTapAddFavoriteOutlet()
        }
    }
    func setup() {
        faveRatingView.layer.cornerRadius = 2
        faveDistanceView.layer.cornerRadius = 2
    }
}

// MARK:- ViewModelBinldable
extension HomeListingTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .distanceHidden
            .drive(faveDistanceView.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .favoritedId
            .asDriver()
            .driveNext { [weak self] (favoritedId: Int) in
                let image = UIImage(
                    named: favoritedId > 0
                        ? "ic_outlet_favourited_fill"
                        : "ic_outlet_favourited_white")
                self?.favouriteButton.setImage(image, forState: UIControlState.Normal)
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .title
            .asDriver()
            .drive(titleLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .companyName
            .asDriver()
            .drive(companyLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .totalOutlet
            .asDriver()
            .drive(totalOutletLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .averageRating
            .asDriver()
            .drive(faveRatingLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .averageRatingViewHidden
            .asDriver()
            .drive(faveRatingView.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .distance
            .asDriver()
            .drive(distanceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .distanceWidth
            .asDriver()
            .driveNext { [weak self] (distanceWidth: CGFloat) in
                self?.distanceWidthConstraint.constant = distanceWidth
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .originalPrice
            .asDriver()
            .drive(originalPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .originalPriceHidden
            .asDriver()
            .drive(originalPriceLabel.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .officialPriceWidth
            .asDriver()
            .driveNext { [weak self] (officialPriceWidth: CGFloat) in
                self?.officialPriceWidthConstraint.constant = officialPriceWidth
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .officialPrice
            .asDriver()
            .drive(officialPriceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .activityImage
            .asDriver()
            .driveNext { [weak self] (value: NSURL?) in
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

        viewModel.listenToFavoriteChange()
    }
}
