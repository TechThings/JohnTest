//
//  CreateChannelFilterCollectionViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class CreateChannelFilterCollectionViewCell: CollectionViewCell {

    @IBOutlet weak var containerView: View!

    // MARK:- ViewModel
    var viewModel: CreateChannelFilterCollectionViewModel!

    // MARK:- Constant

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        self.containerView.layer.cornerRadius = 2.0
    }

    func setup() {
    }

    func setSelectedState(selected: Bool) {
        self.selected = selected
        self.highlighted = selected

        if(selected) {
            let selectedColor = UIColor.faveBlue()
            self.containerView.layer.borderColor = selectedColor.CGColor
            self.containerView.backgroundColor = selectedColor.colorWithAlphaComponent(0.10)
            self.containerView.alpha = 1.0
        } else {
            self.containerView.layer.borderColor = UIColor(hexStringFast: "#E0E6ED").CGColor
            self.containerView.backgroundColor = UIColor.whiteColor()
            self.containerView.alpha = 0.5
        }
    }
}

// MARK:- ViewModelBinldable
extension CreateChannelFilterCollectionViewCell: ViewModelBindable {
    func bind() {
        viewModel.name
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (name) in
                self?.nameLabel.text = name
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.iconURL
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (url: NSURL?) in
                if let url = url {
                    self?.iconImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "image-placeholder"), optionsInfo: [.Transition(ImageTransition.Fade(0.5))], progressBlock: nil, completionHandler: nil)
                } else {
                    self?.iconImageView.image = UIImage(named: "image-placeholder")
                }
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}
