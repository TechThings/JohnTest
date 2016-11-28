//
//  BroadcastMessageCollectionViewCellViewModel.swift
//  fave
//
//  Created by Michael Cheah on 8/20/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import JSQMessagesViewController

/**
 *  @author Michael Cheah
 *
 *  BroadcastMessageCollectionViewCellViewModel
 */
final class BroadcastMessageCollectionViewCellViewModel: ViewModel {

    // MARK:- Input
    let message: JSQMessage

    // MARK:- Output
    let displayText: String

    init(message: JSQMessage) {
        self.message = message
        displayText = message.text
        super.init()
    }

    // MARK:- Life cycle
    deinit {

    }
}
