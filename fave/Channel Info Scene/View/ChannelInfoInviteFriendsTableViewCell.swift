//
//  ChannelInfoInviteFriendsTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 22/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelInfoInviteFriendsTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ChannelInfoInviteFriendsTableViewCellModel!

    @IBAction func addFriendsButtonDidTap(sender: AnyObject) {
        viewModel.addFriendsButtonDidTap.onNext(())
    }
    // MARK:- Constant

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func updateConstraints() {
        bind()
        setup()
        super.updateConstraints()
    }

    private func setup() {
    }
}

extension ChannelInfoInviteFriendsTableViewCell:ViewModelBindable {
    func bind() {
    }
}
