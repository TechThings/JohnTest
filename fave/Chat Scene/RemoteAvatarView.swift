//
// Created by Michael Cheah on 8/23/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import Kingfisher
import JSQMessagesViewController
import RxSwift

protocol RemoteAvatarViewDelegate: class {
   func reloadViewForAvatar()
}

final class RemoteAvatarView: NSObject, JSQMessageAvatarImageDataSource {

    // MARK:- Delegate
    weak var delegate: RemoteAvatarViewDelegate?

    private static let avatarSize: UInt = 30
    private let chatParticipant: ChatParticipant

    private var userInitialAvatarImageSource: JSQMessageAvatarImageDataSource?
    private var remoteAvatarImage: UIImage?

    init(chatParticipant: ChatParticipant) {
        self.chatParticipant = chatParticipant
        super.init()

        if let profileImageUrl = chatParticipant.profileImageUrl {
            KingfisherManager.sharedManager.retrieveImageWithURL(profileImageUrl, optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                let image = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: RemoteAvatarView.avatarSize)
                self.remoteAvatarImage = image
                guard let delegate = self.delegate else {
                    return
                }

                delegate.reloadViewForAvatar()
            }
        }
    }

    func avatarImage() -> UIImage! {
        return remoteAvatarImage
    }

    final class func diameter() -> Int {
        return Int(avatarSize)
    }

    func avatarPlaceholderImage() -> UIImage! {
        if let imageSource = userInitialAvatarImageSource {
            return imageSource.avatarImage()
        } else {
            let colorArray = ["#6284A7", "#F38F4D", "#41BAAF", "#F2C500","#D07DF1","#7F8C8D","#18A6D5","#7CCE53","#FFB600","#5BA3F8"]
            let char = String(chatParticipant.initials).uppercaseString as NSString
            let ascii = String(char.characterAtIndex(0))
            var avatarBackgroundColor = UIColor(hexStringFast:colorArray[0])
            if let ascii_int = Int(ascii) {
                let index = ascii_int % colorArray.count
                avatarBackgroundColor = UIColor(hexStringFast:colorArray[index])
            }
            userInitialAvatarImageSource = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(chatParticipant.initials, backgroundColor: avatarBackgroundColor, textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12.0), diameter: RemoteAvatarView.avatarSize)
            return userInitialAvatarImageSource?.avatarImage()
        }
    }

    func avatarHighlightedImage() -> UIImage! {
        return nil
    }
}
