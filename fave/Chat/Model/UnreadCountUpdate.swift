//
// Created by Michael Cheah on 8/22/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation

final class UnreadCountUpdate: NSObject {
    let channelUrl: String
    let unreadCount: Int

    init(channelUrl: String,
         unreadCount: Int) {
        self.channelUrl = channelUrl
        self.unreadCount = unreadCount
    }
}
