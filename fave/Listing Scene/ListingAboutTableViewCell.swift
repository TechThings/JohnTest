//
//  ListingAboutTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class ListingAboutTableViewCell: TableViewCell {

    @IBOutlet weak var readMoreLabel: UILabel!
    @IBOutlet weak var aboutLabel: KFITLabel!
    @IBOutlet weak var aboutBottomConstraint: NSLayoutConstraint!

    var viewModel: ListingAboutTableViewCellViewModel!

    override func updateConstraints() {
        aboutLabel.lineSpacing = 2.2
        aboutLabel.textAlignment = .Left
        aboutLabel.lineBreakMode = .ByTruncatingTail

        let width = UIScreen .mainScreen().bounds.width
        let height = aboutLabel.text?.heightWithConstrainedWidth(width - 30, font: UIFont.systemFontOfSize(15))
        if height <= 60 {
            readMoreLabel.hidden = true
            aboutBottomConstraint.constant = 15
        }
        super.updateConstraints()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ListingAboutTableViewCell : ViewModelBindable {
    func bind() {

        viewModel.readMore
        .driveNext { [weak self] (value) in
            if value == false {
                self?.readMoreLabel.text = NSLocalizedString("show_more", comment: "")
                self?.aboutLabel.numberOfLines = 3
            } else {
                self?.readMoreLabel.text = NSLocalizedString("show_less", comment: "")
                self?.aboutLabel.numberOfLines = 0
            }
        }
        .addDisposableTo(rx_reusableDisposeBag)

        viewModel.aboutText
        .drive (aboutLabel.rx_text)
        .addDisposableTo(rx_reusableDisposeBag)
    }
}
