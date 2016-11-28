//
//  ProfilePictureView.swift
//  FAVE
//
//  Created by Thanh KFit on 8/18/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfilePictureView: View {

    // MARK:- ViewModel
    var viewModel: ProfilePictureViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var avatarOverlayButton: UIButton!
    @IBOutlet weak var icCameraImageView: UIImageView!

    // MARK:- Constant

    // MARK:- Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    private func setup() {

    }
    @IBAction func didTapAvatarOverlayButton(sender: AnyObject) {
        viewModel.updateProfilePicture()
    }
}

// MARK:- ViewModelBinldable
extension ProfilePictureView: ViewModelBindable {
    func bind() {
        viewModel
            .avatarViewModel
            .asObservable()
            .filterNil()
            .subscribeNext { [weak self] (vm) in
                self?.avatarView.viewModel = vm
            }.addDisposableTo(disposeBag)

        viewModel
            .canEditing
            .asDriver()
            .driveNext { [weak self](canEditing) in
                self?.avatarOverlayButton.hidden = !canEditing
                self?.icCameraImageView.hidden = !canEditing
            }.addDisposableTo(disposeBag)

    }
}
