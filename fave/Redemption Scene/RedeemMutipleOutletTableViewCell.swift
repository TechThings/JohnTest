//
//  RedeemMutipleOutletTableViewCell.swift
//  MultipleOutlet
//
//  Created by Thanh KFit on 10/14/16.
//  Copyright © 2016 Thanh KFit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RedeemMutipleOutletTableViewCell: UITableViewCell {

    var viewModel: RedeemMultipleOutletTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var selectedImageView: UIImageView!

    @IBOutlet weak var outletNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension RedeemMutipleOutletTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.outletName
            .drive(outletNameLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel.selectedImage
            .asDriver()
            .drive(selectedImageView.rx_image)
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
