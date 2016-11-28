//
//  ParticipantAvatarViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 23/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ParticipantAvatarView
 */
final class ParticipantAvatarViewModel: ViewModel {
    // MARK:- Output
    let avatarImageURL: Driver<NSURL?>
    let initals: Driver<String>
    let avatarColor: Driver<UIColor>
    let participationImage: Driver<UIImage>

    // MARK:- Input
    let avatar: Variable<Avatarable>

    init(
        avatar: Variable<Avatarable>
        ) {
        self.avatar = avatar
        avatarImageURL = avatar.asDriver().map { (avatar: Avatarable) -> NSURL? in avatar.imageURL }
        initals = avatar.asDriver().map { (avatar: Avatarable) -> String in
            if let lastLetter = avatar.lastLetter {
                return (String(avatar.firstLetter) + String(lastLetter)).uppercaseString
            }
            return String(avatar.firstLetter).uppercaseString
        }

        avatarColor = avatar.asDriver().map { (avatar: Avatarable) -> UIColor in
            let colorArray = ["#6284A7", "#F38F4D", "#41BAAF", "#F2C500","#D07DF1","#7F8C8D","#18A6D5","#7CCE53","#FFB600","#5BA3F8"]
            let char = String(avatar.firstLetter).uppercaseString as NSString
            let ascii = String(char.characterAtIndex(0))
            guard let ascii_int = Int(ascii) else {
                return UIColor(hexStringFast:colorArray[0])
            }

            let index = ascii_int % colorArray.count
            return UIColor(hexStringFast:colorArray[index])
        }

        participationImage = { () -> Driver<UIImage> in
            switch avatar.value.participationStatus {
            case .NotInvited:
                return Driver.of(UIImage())
            case .Invited:
                return Driver.of(UIImage())
            case .Maybe:
                return Driver.of(UIImage(named: "ic_invite_answer_maybe")!)
            case .Going:
                return Driver.of(UIImage(named: "ic_invite_answer_yes")!)
            case .NotGoing:
                return Driver.of(UIImage(named: "ic_invite_answer_no")!)
            }
        }()
        super.init()

    }
}
