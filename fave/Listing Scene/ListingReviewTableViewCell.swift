//
//  ListingReviewTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingReviewTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: ListingReviewTableViewCellViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet

    @IBOutlet weak var avatarBackgroundView: UIView!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var commentLabel: KFITLabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarBackgroundView.layer.cornerRadius = 20
    }
}

// MARK:- ViewModelBinldable
extension ListingReviewTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.avatar.drive(self.avatarLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.name.drive(self.nameLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.comment.drive(self.commentLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.rating.drive(self.ratingLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        commentLabel.lineSpacing = 2.2
        commentLabel.textAlignment = .Left
    }
}
