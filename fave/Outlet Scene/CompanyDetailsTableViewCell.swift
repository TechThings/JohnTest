//
//  CompanyDetailsTableViewCell.swift
//  FAVE
//
//  Created by Michael Cheah on 7/12/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class CompanyDetailsTableViewCell: TableViewCell {

    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companyDetails: KFITLabel!
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var profileIconImage: UIImageView!

    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingViewRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var favoritedLabel: UILabel!
    @IBOutlet weak var favoritedViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoritedViewRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var offerLabel: UILabel!
    @IBOutlet weak var offerViewWidthConstraint: NSLayoutConstraint!

    // MARK:- ViewModel
    var viewModel: CompanyDetailsViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        profileIconImage.layer.borderWidth = 4
        profileIconImage.layer.borderColor = UIColor.whiteColor().CGColor
        profileIconImage.layer.cornerRadius = 3
        ratingView.layer.cornerRadius = 2

        // Nothing as of now
    }
}

extension CompanyDetailsTableViewCell: ViewModelBindable {
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

        if let profileIconImage = viewModel.companyProfileIconImage {
            self.profileIconImage.kf_setImageWithURL(
                    profileIconImage,
                    placeholderImage: UIImage(named: "image-placeholder"),
                    optionsInfo: [.Transition(ImageTransition.Fade(0.5))],
                    progressBlock: nil,
                    completionHandler: nil)
        } else {
            self.profileIconImage.image = UIImage(named: "image-placeholder")
        }

        self.companyName.text = viewModel.companyName
        self.companyDetails.text = viewModel.companyDetails
        self.companyDetails.lineSpacing = 2.2
        self.companyDetails.textAlignment = .Left

        self.ratingLabel.text = viewModel.partnerAverageRatingText
        self.ratingViewWidthConstraint.constant = viewModel.partnerAverageRatingWidth
        self.ratingViewRightConstraint.constant = viewModel.partnerAverageRatingRight
        self.favoritedLabel.text = viewModel.partnerFavoritedCountText
        self.favoritedViewWidthConstraint.constant = viewModel.partnerFavoritedCountWidth
        self.favoritedViewRightConstraint.constant = viewModel.partnerFavoritedCountRight
        self.offerLabel.text = viewModel.partnerOffersCountText
        self.offerViewWidthConstraint.constant = viewModel.partnerOffersCountWidth
    }
}
