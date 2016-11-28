//
//  ChannelsHeaderViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 11/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ChannelsHeaderViewModel
 */
final class ChannelsHeaderViewModel: ViewModel {

    // MARK- Output
    let title: Driver<String> = Driver.of(NSLocalizedString("chat_do_more_together", comment: ""))
    let subTitle: Driver<String> = Driver.of(NSLocalizedString("plan_with_friends", comment: ""))

    init(
        ) {
        super.init()

    }
}
