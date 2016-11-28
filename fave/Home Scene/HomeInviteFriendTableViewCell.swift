//
//  HomeInviteFriendTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class HomeInviteFriendTableViewCell: TableViewCell {
    // MARK:- @IBOutlet
    @IBOutlet weak var descriptionLabel: KFITLabel!

    // MARK:- @IBAction
    @IBAction func openCreditButtonDidTap(sender: UIButton) {
        viewModel.openCreditButtonDidTap.onNext(())
    }

    // MARK:- ViewModel
    var viewModel: HomeInviteFriendTableViewCellViewModel! {
        didSet { bind() }
    }

}

extension HomeInviteFriendTableViewCell: ViewModelBindable {
    func bind() {
        descriptionLabel.lineSpacing = 2.3
        descriptionLabel.textAlignment = .Left
    }
}
