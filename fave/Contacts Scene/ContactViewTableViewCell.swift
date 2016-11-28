//
//  ContactViewTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ContactViewTableViewCell: TableViewCell {
    // MARK:- @IBOutlet
    // MARK:- ViewModel
    var viewModel: ContactViewTableViewCellModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var participantAvatarView: ParticipantAvatarView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!

    @IBAction func selectContactVuttonDidTap(sender: UIControl) {
        viewModel.didTap.onNext(())
    }
    override func updateConstraints() {
        super.updateConstraints()
    }
}

// MARK:- ViewModelBinldable
extension ContactViewTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .contact
            .asDriver()
            .driveNext { [weak self] (avatar: Avatarable) in
                let avatarViewModel = ParticipantAvatarViewModel(avatar: Variable(avatar))
                guard let view = self?.participantAvatarView else {
                    return
                }

                view.viewModel = avatarViewModel
                view.layer.cornerRadius = view.frame.size.width/2
                view.croppedView.layer.cornerRadius = view.frame.size.width/2
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .name
            .drive(nameLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .phoneNumber
            .drive(phoneNumberLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .selectedImage
            .drive(selectedImageView.rx_image)
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
