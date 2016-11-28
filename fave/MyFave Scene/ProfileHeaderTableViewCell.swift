//
//  ProfileHeaderTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ProfileHeaderTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: ProfileHeaderViewModel!

    // MARK:- Constant

    // MARK:- IBOutlets

    @IBOutlet weak var avatarWrapView: UIView!
    @IBOutlet weak var userInitialLabel: UILabel!
    //@IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        avatarWrapView.layer.cornerRadius = avatarWrapView.frame.size.height/2
    }
}

// MARK:- ViewModelBinldable
extension ProfileHeaderTableViewCell: ViewModelBindable {
    func bind() {

//        viewModel.avatarPhoto
//            .asObservable()
//            .subscribeOn(MainScheduler.instance)
//            .subscribeNext { [weak self]
//                value in
//                self?.avatarImageView.kf_setImageWithURL(
//                    value!,
//                    placeholderImage: UIImage(named: "image-placeholder"),
//                    optionsInfo: [.Transition(ImageTransition.Fade(0.5))],
//                    progressBlock: nil,
//                    completionHandler: nil)
//            }.addDisposableTo(disposeBag)

        viewModel.name
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.nameLabel.text = $0
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}
