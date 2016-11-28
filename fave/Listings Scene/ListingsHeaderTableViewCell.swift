//
//  ListingsHeaderTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ListingsHeaderTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: ListingsHeaderTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var backgroundImageView: UIImageView!
    // MARK:- Constant

    @IBOutlet weak var descriptionLabel: KFITLabel!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable
extension ListingsHeaderTableViewCell: ViewModelBindable {
    func bind() {
        backgroundImageView.kf_setImageWithURL(viewModel.backgroundImage,
            placeholderImage: UIImage(named: "image-placeholder"),
            optionsInfo: [.Transition(ImageTransition.Fade(0.5))],
            progressBlock: nil,
            completionHandler: nil)
        descriptionLabel.text = viewModel.categoryDescription
    }
}
