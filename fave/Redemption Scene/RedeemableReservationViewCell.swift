//
//  RedeemableReservationViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RedeemableReservationViewCell: TableViewCell {

    // MARK:- ViewModel

    // MARK:- @IBOutlet
    @IBOutlet weak var redeemableReservationView: RedeemableReservationView!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }

    override func prepareForReuse() {

        //CC: Make `redeemConfirmRequest` subscribe only one time
        redeemableReservationView
            .viewModel
            .redeemConfirmRequest
            .dispose()
    }
}
