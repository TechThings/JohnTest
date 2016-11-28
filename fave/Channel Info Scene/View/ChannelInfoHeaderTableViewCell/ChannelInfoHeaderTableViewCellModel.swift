//
//  ChannelInfoHeaderViewCellModel.swift
//  FAVE
//
//  Created by Michael Cheah on 8/14/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  ChannelInfoHeaderViewCellModel
 */
final class ChannelInfoHeaderTableViewCellModel: ViewModel {

    // MARK- Output
    let chatTitle: String

    init(chatTitle: String) {
        self.chatTitle = chatTitle
        super.init()
    }
}
