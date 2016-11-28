//
//  FaveContactHeaderTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 12/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FaveContactHeaderTableViewCell: TableViewCell {

    // MARK:- @IBOutlet
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        title.text = NSLocalizedString("friends", comment: "")

    }

}
