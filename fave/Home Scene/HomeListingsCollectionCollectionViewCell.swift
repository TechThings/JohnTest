//
//  HomeListingsCollectionCollectionViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/2/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeListingsCollectionCollectionViewCell: CollectionViewCell {

    // MARK:- ViewModel
    var viewModel: HomeListingsCollectionCollectionViewCellViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: KFITLabel!
    @IBOutlet weak var offersCountLabel: UILabel!
    @IBOutlet weak var offersCountImage: UIImageView!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable
extension HomeListingsCollectionCollectionViewCell: ViewModelBindable {
    func bind() {
        viewModel.name
            .asDriver()
            .drive(nameLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel.collectionDescription
            .asDriver()
            .drive(descriptionLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel.imageURL
            .asDriver()
            .driveNext({ [weak self](url) in
                if let url = url {
                    self?.photoImageView.kf_setImageWithURL(
                        url
                        , placeholderImage: UIImage(named: "image-placeholder")
                        , optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                } else {
                    self?.photoImageView.image = UIImage(named: "image-placeholder")
                }
            }).addDisposableTo(rx_reusableDisposeBag)

        viewModel.numberOfOffers.drive(offersCountLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.offersImageHidden.drive(offersCountImage.rx_hidden).addDisposableTo(rx_reusableDisposeBag)

        descriptionLabel.lineSpacing = 2.2
        descriptionLabel.textAlignment = .Left
    }
}
