//
//  ChannelInfoHeaderTableViewCell.swift
//  FAVE
//
//  Created by Michael Cheah on 8/14/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelInfoHeaderTableViewCell: TableViewCell {

    // MARK:- IBOutlet
    @IBOutlet weak var chatTitleLabel: UILabel!

    // MARK:- ViewModel
    var viewModel: ChannelInfoHeaderTableViewCellModel!

    override func updateConstraints() {
        bind()
        super.updateConstraints()
    }
}

// MARK:- ViewModelBinldable
extension ChannelInfoHeaderTableViewCell: ViewModelBindable {
    func bind() {
        self.chatTitleLabel.text = viewModel.chatTitle
    }
}
