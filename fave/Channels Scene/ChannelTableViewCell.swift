//
//  ChannelTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelTableViewCell: TableViewCell {

    // MARK:- @IBOutlet
    @IBOutlet weak var channelView: ChannelView!

    override func prepareForReuse() {
        self.channelView.prepareForCellReuse()
    }
}
