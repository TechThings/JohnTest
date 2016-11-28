//
//  ListingOutletTableViewCell.swift
//  KFIT
//
//  Created by Nazih Shoura on 14/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import Kingfisher

final class ListingOutletTableViewCell: TableViewCell {

    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBOutlet weak var outletNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var faveButton: UIButton!

    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingViewRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var favoritedLabel: UILabel!
    @IBOutlet weak var favoritedViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoritedViewRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var offerLabel: UILabel!
    @IBOutlet weak var offerViewWidthConstraint: NSLayoutConstraint!

    var viewModel: ListingOutletTableViewCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.layer.cornerRadius = 2
    }

    @IBAction func didTapFaveButton(sender: AnyObject) {
        if viewModel.favoritedId.value > 0 {
            let image = UIImage(named: "ic_outlet_favourited_pink")
            faveButton.setImage(image, forState: UIControlState.Normal)
            viewModel.deleteFavoriteOutlet()
        } else {
            let image = UIImage(named: "ic_outlet_favourited_fill")
            faveButton.setImage(image, forState: UIControlState.Normal)
            viewModel.didTapAddFavoriteOutlet()
        }
    }
}

extension ListingOutletTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.distanceHidden.drive(distanceLabel.rx_hidden).addDisposableTo(rx_reusableDisposeBag)

        viewModel.favoritedId
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (favoritedId: Int) in
                var image: UIImage!
                if favoritedId > 0 {
                    image = UIImage(
                        named: "ic_outlet_favourited_fill")
                } else {
                    image = UIImage(
                        named: "ic_outlet_favourited_pink")
                }
                self?.faveButton.setImage(image, forState: UIControlState.Normal)
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerName
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (partnerName: String) in
                self?.partnerNameLabel.text = partnerName
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.outletName
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (outletName: String) in
                self?.outletNameLabel.text = outletName
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.outletDistance
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (outletDistance: String) in
                self?.distanceLabel.text = outletDistance
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerProfileImageURL
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (value: NSURL?) in
                if let value = value {
                    self?.partnerImageView.kf_setImageWithURL(
                        value
                        , placeholderImage: UIImage(named: "image-placeholder")
                        , optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                } else {
                    self?.partnerImageView.image = UIImage(named: "image-placeholder")
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerAverageRatingText
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (partnerAverageRatingText: String) in
                self?.ratingLabel.text = partnerAverageRatingText
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerAverageRatingWidth
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (partnerAverageRatingWidth: CGFloat) in
                self?.ratingViewWidthConstraint.constant = partnerAverageRatingWidth
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerAverageRatingRight
            .asObservable()
            .subscribeNext { [weak self] (partnerAverageRatingRight: CGFloat) in
                self?.ratingViewRightConstraint.constant = partnerAverageRatingRight
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerFavoritedCountText
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (partnerFavoritedCountText: String) in
                self?.favoritedLabel.text = partnerFavoritedCountText
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerFavoritedCountWidth
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (partnerFavoritedCountWidth: CGFloat) in
                self?.favoritedViewWidthConstraint.constant = partnerFavoritedCountWidth
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerFavoritedCountRight
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (partnerFavoritedCountRight: CGFloat) in
                self?.favoritedViewRightConstraint.constant = partnerFavoritedCountRight
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerOffersCountText
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (partnerOffersCountText: String) in
                self?.offerLabel.text = partnerOffersCountText
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerOffersCountWidth
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (partnerOffersCountWidth: CGFloat) in
                self?.offerViewWidthConstraint.constant = partnerOffersCountWidth
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.listenToFavoriteChange()
    }
}
