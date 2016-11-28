//
//  OnboardingContentCell.swift
//  FAVE
//
//  Created by Thanh KFit on 6/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class OnboardingContentCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var contentLabel: KFITLabel!
    @IBOutlet weak var titleLabel: UILabel!

    var viewModel : (bgImage: UIImage, message: String, icon: UIImage, title: String)? {
        didSet {
            backgroundImageView.image = viewModel!.bgImage
            iconImageView.image = viewModel!.icon
            titleLabel.text = viewModel!.title
            contentLabel.text = viewModel!.message
            contentLabel.lineSpacing = 2.5
        }
    }
}
