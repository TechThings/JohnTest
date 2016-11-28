//
//  ParticipantAvatarView.swift
//  FAVE
//
//  Created by Nazih Shoura on 23/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ParticipantAvatarView: View {

    // MARK:- ViewModel
    var viewModel: ParticipantAvatarViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var initalsLabel: UILabel!
    @IBOutlet weak var participationImageView: UIImageView!
    @IBOutlet weak var croppedView: UIView! {
        didSet { croppedView.layer.cornerRadius = croppedView.frame.size.height/2 }
    }

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
        self.alpha = 0
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(String(ParticipantAvatarView), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    private func setup() {
        croppedView.layer.cornerRadius = croppedView.frame.size.width/2
        participationImageView.layer.cornerRadius = participationImageView.frame.size.width/2
    }

    func makeRound() {
        croppedView.layer.cornerRadius = croppedView.frame.size.width/2
        updateConstraints()
    }
}

// MARK:- ViewModelBinldable
extension ParticipantAvatarView: ViewModelBindable {
    func bind() {
        viewModel
        .avatarImageURL
        .driveNext { [weak self] (url: NSURL?) in
            guard let url = url else {self?.avatarImageView.image = nil; return}

            self?.avatarImageView.kf_setImageWithURL(
                url
                , placeholderImage: nil
                , optionsInfo: [.Transition(ImageTransition.Fade(0.5))]
            )
            }.addDisposableTo(disposeBag)

        viewModel.initals.drive(initalsLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.avatarColor
            .driveNext {
                self.croppedView.backgroundColor = $0
            }.addDisposableTo(disposeBag)

        viewModel.participationImage
            .driveNext {
                self.participationImageView.image = $0
            }.addDisposableTo(disposeBag)

        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 1
        })
    }
}
