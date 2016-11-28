//
//  AvatarView.swift
//  FAVE
//
//  Created by Thanh KFit on 8/18/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class AvatarView: View {

    // MARK:- ViewModel
    var viewModel: AvatarViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var avatarImageView: SwiftyAvatar!

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

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        super.updateConstraints()
    }

}

// MARK:- ViewModelBinldable
extension AvatarView: ViewModelBindable {
    func bind() {
        viewModel
            .profileImageURL
            .driveNext {
                [weak self] (url: NSURL?) in
                if let url = url {
                    self?.avatarImageView.kf_setImageWithURL(
                        url
                        , placeholderImage: UIImage(named: "image-placeholder")
                        , optionsInfo: [.Transition(ImageTransition.Fade(0.5))]
                    )
                }
            }.addDisposableTo(disposeBag)

        viewModel
            .initial
            .drive(initialLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .initialHidden
            .asDriver()
            .driveNext { [weak self] (hidden) in
                self?.initialLabel.hidden = hidden
            }.addDisposableTo(disposeBag)
    }
}
