//
//  RedeemedReservationViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 14/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RedeemedReservationViewCell: TableViewCell {

    // MARK:- Life cycle

    @IBOutlet weak var redeemedReservationView: RedeemedReservationView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}
