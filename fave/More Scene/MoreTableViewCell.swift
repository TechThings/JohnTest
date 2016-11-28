//
//  MoreTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MoreTableViewCell: TableViewCell {

    // MARK:- IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    // MARK:- ViewModel
    var viewModel: MoreTableViewCellViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable
extension MoreTableViewCell: ViewModelBindable {
    func bind() {
        detailLabel.text = viewModel.detail

        titleLabel.text = viewModel.title
        titleLabel.text = viewModel.title
        iconImageView.image = viewModel.iconImage
    }
}
