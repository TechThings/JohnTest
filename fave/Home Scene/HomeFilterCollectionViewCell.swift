//
//  HomeFilterCollectionViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeFilterCollectionViewCell: CollectionViewCell {

    // MARK:- ViewModel
    var viewModel: HomeFilterCollectionViewCellViewModel!

    // MARK:- Constant

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        self.layer.cornerRadius = 2.0
    }
}

// MARK:- ViewModelBinldable
extension HomeFilterCollectionViewCell: ViewModelBindable {
    func bind() {
        viewModel.name
            .asDriver()
            .drive(nameLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel.iconURL
            .asDriver()
            .driveNext({ [weak self] (url) in
                guard let url = url else {
                    self?.iconImageView.image = UIImage(named: "image-placeholder")
                    return
                }
                self?.iconImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "image-placeholder"), optionsInfo: [.Transition(ImageTransition.Fade(0.5))], progressBlock: nil, completionHandler: nil)
            }).addDisposableTo(rx_reusableDisposeBag)
    }
}
