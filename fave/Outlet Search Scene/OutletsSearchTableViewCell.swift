//
//  OutletsSearchTableViewCell.swift
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

final class OutletsSearchTableViewCell: TableViewCell {

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

    var viewModel: OutletsSearchTableViewCellModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 2
        ratingView.layer.cornerRadius = 2
    }

    @IBAction func didTapFaveButton(sender: AnyObject) {
        outlet(didChangeFavorite: viewModel.favoritedId.value > 0)
        if viewModel.favoritedId.value > 0 {
            let image = UIImage(
                named: "ic_outlet_favourited_pink")
            faveButton.setImage(image, forState: UIControlState.Normal)
            viewModel.deleteFavoriteOutlet()
        } else {
            viewModel.didTapAddFavoriteOutlet()
        }
    }

    func outlet(didChangeFavorite favorited: Bool) {
        if favorited {
            let image = UIImage(
                named: "ic_outlet_favourited_fill")
            faveButton.setImage(image, forState: UIControlState.Normal)
        } else {
            let image = UIImage(
                named: "ic_outlet_favorited_false")
            faveButton.setImage(image, forState: UIControlState.Normal)
        }
    }
}

extension OutletsSearchTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.distanceHidden.drive(distanceLabel.rx_hidden).addDisposableTo(rx_reusableDisposeBag)
        viewModel.favoritedId
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (favoritedId) in
                let image = UIImage(
                    named: favoritedId > 0
                        ? "ic_outlet_favourited_fill"
                        : "ic_outlet_favourited_pink")
                self?.faveButton.setImage(image, forState: UIControlState.Normal)
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerName
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.partnerNameLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.outletName
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.outletNameLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.outletDistance
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.distanceLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerProfileImageURL
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self]
                (value) in
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
            .subscribeNext { [weak self] in
                self?.ratingLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerAverageRatingWidth
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.ratingViewWidthConstraint.constant = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerAverageRatingRight
            .asObservable()
            .subscribeNext { [weak self] in
                self?.ratingViewRightConstraint.constant = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerFavoritedCountText
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.favoritedLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerFavoritedCountWidth
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.favoritedViewWidthConstraint.constant = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerFavoritedCountRight
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.favoritedViewRightConstraint.constant = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerOffersCountText
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.offerLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.partnerOffersCountWidth
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.offerViewWidthConstraint.constant = $0
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}
