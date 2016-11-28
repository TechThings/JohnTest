//
//  ActivePromoCountCell.swift
//  KFIT
//
//  Created by Nazih Shoura on 12/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class ActivePromoCountCell: UITableViewCell {

    // MARK: @IBOutlet internal
    @IBOutlet weak var activePromoCountView: ActivePromoCountView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func setup() {
    }
}
