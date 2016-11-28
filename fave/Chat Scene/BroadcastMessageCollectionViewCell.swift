//
//  BroadcastMessageCollectionViewCell.swift
//  fave
//
//  Created by Michael Cheah on 8/20/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import JSQMessagesViewController

final class BroadcastMessageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var broadcastMessageLabel: UILabel!
    @IBOutlet weak var broadcastLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var broadcastLabelHeightConstraint: NSLayoutConstraint!

    // MARK:- ViewModel
    var viewModel: BroadcastMessageCollectionViewCellViewModel! {
        didSet {
            bind()
        }
    }

    // MARK:- Constant

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    private func setup() {
        broadcastMessageLabel.backgroundColor = UIColor(hexStringFast: "#E3E6E9")
        broadcastMessageLabel.layer.masksToBounds = true
        // CC: CR fix - Apple
        broadcastMessageLabel.layer.cornerRadius = 10
        broadcastMessageLabel.preferredMaxLayoutWidth = ChatViewController.broadcastMessageWidth - ChatViewController.broadcastMessagePadding
        broadcastLabelWidthConstraint.constant = ChatViewController.broadcastMessageWidth
    }

}

// MARK:- ViewModelBinldable

extension BroadcastMessageCollectionViewCell: ViewModelBindable {
    func bind() {
        broadcastMessageLabel.text = viewModel.displayText
        let height = viewModel.displayText.heightWithConstrainedWidth(ChatViewController.broadcastMessageWidth - ChatViewController.broadcastMessagePadding,
                                                                      font: ChatViewController.broadcastMessageFont)
        broadcastLabelHeightConstraint.constant = height + ChatViewController.broadcastMessagePadding
    }
}
