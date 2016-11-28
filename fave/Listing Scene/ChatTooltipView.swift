//
//  ChatTooltipView.swift
//  FAVE
//
//  Created by Gautam on 12/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AMPopTip

final class ChatTooltipView: View {

    // MARK:- IBOutlet/IBAction
    @IBOutlet weak var gotItButton: UIButton!
    let toolTip = AMPopTip()

    @IBAction func gotItButtonTapped (sender: UIButton) {
    //
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureToolTip (sender: UIView, chatButton: UIButton) {

        toolTip.shouldDismissOnTapOutside = false
        toolTip.popoverColor = UIColor.whiteColor()
        toolTip.entranceAnimation = AMPopTipEntranceAnimation.FadeIn
        toolTip.animationIn = 0.8
        toolTip.edgeMargin = 10
        toolTip.actionAnimation = AMPopTipActionAnimation.Bounce

        let finalFrame = CGRectMake(10, sender.frame.size.height-20-chatButton.frame.size.height, chatButton.frame.size.width, chatButton.frame.size.height)

        toolTip.showCustomView(self, direction: AMPopTipDirection.Up, inView: sender, fromFrame: finalFrame)

    }

    func dismissToolTip () {
        self.toolTip.hide()
        self.toolTip .removeFromSuperview()
    }
}
