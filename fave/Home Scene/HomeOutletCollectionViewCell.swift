//
//  HomeOutletCollectionViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeOutletCollectionViewCell: CollectionViewCell {

    // MARK:- ViewModel
    var viewModel: OutletsSearchTableViewCellModel!

    // MARK:- IBOutlets

    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var outletLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var addFaveButton: UIButton!

    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingViewRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var favoritedLabel: UILabel!
    @IBOutlet weak var favoritedViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoritedViewRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var offerLabel: UILabel!
    @IBOutlet weak var offerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var removeFaveButton: UIButton!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    @IBAction func didTapAddFaveButton(sender: AnyObject) {
        viewModel.didTapAddFavoriteOutlet()
        configAddFaveButton(true)
    }

    @IBAction func didTapRemoveFaveButton(sender: AnyObject) {
        viewModel.deleteFavoriteOutlet()
        configAddFaveButton(false)
    }

    func setup() {
        ratingView.layer.cornerRadius = 2

        addFaveButton.layer.cornerRadius = 2
        addFaveButton.layer.borderWidth = 0.5
        addFaveButton.layer.borderColor = UIColor.favePink().CGColor
        self.addFaveButton.setTitle(" " + NSLocalizedString("home_add_to_my_fave_button_text", comment: ""), forState: .Normal)
        self.removeFaveButton.setTitle(" " + NSLocalizedString("home_add_to_my_fave_button_text", comment: ""), forState: .Normal)

    }

    func configAddFaveButton(isFavorited: Bool) {
        if isFavorited {
            removeFaveButton.hidden = false
        } else {
            removeFaveButton.hidden = true
        }
    }

    @IBAction func didTapOverlayButton(sender: AnyObject) {
        viewModel.showPartnerDetails()
    }

}

// MARK:- ViewModelBinldable
extension HomeOutletCollectionViewCell: ViewModelBindable {
    func bind() {

        viewModel
            .favoritedId
            .asDriver()
            .driveNext { [weak self] (favoritedId: Int) in
                self?.configAddFaveButton(favoritedId > 0)
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerName
            .asDriver()
            .drive(partnerLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .outletName
            .asDriver()
            .drive(outletLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerProfileImageURL
            .asDriver()
            .driveNext { [weak self]  (value: NSURL?) in
                if let value = value {
                    self?.contentImage.kf_setImageWithURL(
                        value
                        , placeholderImage: UIImage(named: "image-placeholder")
                        , optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                } else {
                    self?.contentImage.image = UIImage(named: "image-placeholder")
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerAverageRatingText
            .asDriver()
            .drive(ratingLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerAverageRatingWidth
            .asDriver()
            .driveNext { [weak self] (partnerAverageRatingWidth: CGFloat) in
                self?.ratingViewWidthConstraint.constant = partnerAverageRatingWidth
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerAverageRatingRight
            .asDriver()
            .driveNext { [weak self] (partnerAverageRatingRight: CGFloat) in
                self?.ratingViewRightConstraint.constant = partnerAverageRatingRight
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerFavoritedCountText
            .asDriver()
            .drive(favoritedLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerFavoritedCountWidth
            .asDriver()
            .driveNext { [weak self] (partnerFavoritedCountWidth: CGFloat) in
                self?.favoritedViewWidthConstraint.constant = partnerFavoritedCountWidth
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerFavoritedCountRight
            .asDriver()
            .driveNext { [weak self] (partnerFavoritedCountRight: CGFloat) in
                self?.favoritedViewRightConstraint.constant = partnerFavoritedCountRight
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerOffersCountText
            .asDriver()
            .drive(offerLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .partnerOffersCountWidth
            .asDriver()
            .driveNext { [weak self] (partnerOffersCountWidth: CGFloat) in
                self?.offerViewWidthConstraint.constant = partnerOffersCountWidth
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.listenToFavoriteChange()
    }
}
