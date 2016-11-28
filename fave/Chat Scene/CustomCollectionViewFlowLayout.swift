//
// Created by Michael Cheah on 8/20/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import JSQMessagesViewController

final class CustomCollectionViewFlowLayout: JSQMessagesCollectionViewFlowLayout {
    override func messageBubbleSizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
        // Reduce cell size for the Broadcast message

        let data = self.collectionView.dataSource.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
        if let jsqMessage = data as? JSQMessage where jsqMessage.isBroadcast {
            let height = jsqMessage.text.heightWithConstrainedWidth(ChatViewController.broadcastMessageWidth - ChatViewController.broadcastMessagePadding, font: ChatViewController.broadcastMessageFont)
            return CGSizeMake(ChatViewController.broadcastMessageWidth, height + ChatViewController.broadcastMessageCellMargin)
        }

        return super.messageBubbleSizeForItemAtIndexPath(indexPath)
    }
}
