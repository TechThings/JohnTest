//
//  UserProfileHeaderTableViewCell.swift
//  fave
//
//  Created by Michael Cheah on 7/14/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class UserProfileHeaderTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: UserProfileHeaderViewModel!

    @IBOutlet weak var profilePictureView: ProfilePictureView!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK:- ViewModelBinldable
extension UserProfileHeaderTableViewCell: ViewModelBindable {
    func bind() {
        let vm = ProfilePictureViewModel(canEditing: true)
        profilePictureView.viewModel = vm
    }
}
