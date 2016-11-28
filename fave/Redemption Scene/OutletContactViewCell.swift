//
//  OutletContactViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OutletContactViewCell: TableViewCell {
     // MARK:- Life cycle

    @IBOutlet weak var outletContactView: OutletContactView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}
