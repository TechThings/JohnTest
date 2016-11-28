//
//  OutletTimeslotOfferTableViewCell.swift
//  fave
//
//  Created by Michael Cheah on 7/13/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OutletTimeslotOfferTableViewCell: OutletVoucherOfferTableViewCell {

    @IBOutlet weak var nextSessionDateTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func bind() {
        self.nextSessionDateTime.text = viewModel.nextClassSessionDateTime

        super.bind()
    }
}
