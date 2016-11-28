//
//  ViewAllMultipleOutletsTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewAllMultipleOutletsTableViewCell: TableViewCell {
     // MARK:- Life cycle

    @IBOutlet weak var viewAllMultipleOutletsView: ViewAllMultipleOutletsView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}
