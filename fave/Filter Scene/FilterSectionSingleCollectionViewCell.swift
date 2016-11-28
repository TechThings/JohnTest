//
//  FilterSectionSingleCollectionViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 9/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class FilterSectionSingleCollectionViewCell: CollectionViewCell {

    var viewModel: FilterSectionSingleCollectionViewCellViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        // Initialization code
    }

    func updateCell(selected: Bool) {
        if selected {
            button.setBackgroundColor(UIColor.favePink(), forState: UIControlState.Normal)
            button.layer.borderColor = UIColor.clearColor().CGColor
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        } else {
            button.setBackgroundColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.layer.borderColor = UIColor(red: 137.0/255.0, green: 153.0/255.0, blue: 168.0/255.0, alpha: 0.39).CGColor
            button.setTitleColor(UIColor(red: 137.0/255.0, green: 153.0/255.0, blue: 168.0/255.0, alpha: 1), forState: UIControlState.Normal)
        }

        viewModel.isSelected = selected
    }

}

extension FilterSectionSingleCollectionViewCell: ViewModelBindable {
    func bind() {

        updateCell(viewModel.isSelected)

        viewModel.label
            .drive(self.button.rx_title(UIControlState.Normal))
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
