//
//  FilterCategoryCollectionViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/25/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import Kingfisher

final class FilterCategoryCollectionViewCell: CollectionViewCell {

    var viewModel: FilterCategoryCollectionViewCellViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.layer.cornerRadius = ((UIScreen.mainWidth - 60)/5 - 16)/2.0
        iconView.layer.masksToBounds = true
        // Initialization code
    }

    func updateSelected() {
        viewModel.updateSelected()
    }
}

extension FilterCategoryCollectionViewCell: ViewModelBindable {
    func bind() {
        viewModel.name.drive(titleLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)

        viewModel.icon.filterNil().driveNext { [weak self] (url) in
            self?.iconImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "image-placeholder"), optionsInfo: [.Transition(ImageTransition.Fade(0.5))], progressBlock: nil, completionHandler: nil)
        }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.color.asDriver().driveNext { [weak self] (color) in
            self?.iconView.backgroundColor = color
        }.addDisposableTo(rx_reusableDisposeBag)
    }
}
