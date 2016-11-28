//
//  ListingCollectionTableViewCell.swift
//  fave
//
//  Created by Michael Cheah on 7/17/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ListingCollectionTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: ListingsCollectionHeaderViewModel!

    // MARK:- Constant
    @IBOutlet weak var collectionImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var collectionDescription: KFITLabel!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

// MARK:- ViewModelBinldable
extension ListingCollectionTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.collectionDescription.drive(collectionDescription.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.name.drive(name.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel
            .imageURL
            .driveNext { [weak self] (value: NSURL?) in
                if let value = value {
                    self?.collectionImage.kf_setImageWithURL(
                        value
                        , placeholderImage: UIImage(named: "image-placeholder")
                        , optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                } else {
                    self?.collectionImage.image = UIImage(named: "image-placeholder")
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        collectionDescription.lineSpacing = 2.2
        collectionDescription.textAlignment = .Center
    }
}
