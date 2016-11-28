//
//  ParticipantsView.swift
//  FAVE
//
//  Created by Nazih Shoura on 23/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ParticipantsView: View {

    // MARK:- ViewModel
    var viewModel: ParticipantsViewModel! {
        didSet {bind()}
    }

    // MARK:- IBOutlet
    @IBOutlet weak var stackViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarStackView: UIStackView!
    @IBOutlet weak var avatarView_0: ParticipantAvatarView!
    @IBOutlet weak var avatarView_1: ParticipantAvatarView!
    @IBOutlet weak var avatarView_2: ParticipantAvatarView!
    @IBOutlet weak var avatarView_3: ParticipantAvatarView!
    @IBOutlet weak var avatarView_4: ParticipantAvatarView!
    @IBOutlet weak var restOfAvatarsView: UIView! {
        didSet {
            restOfAvatarsView.layer.cornerRadius = restOfAvatarsView.frame.size.height/2
            restOfAvatarsView.alpha = 0
        }
    }
    @IBOutlet weak var restOfAvatarsLabel: UILabel!

    // MARK:- Constant
    var avatarViews: [ParticipantAvatarView] {
        return [avatarView_0, avatarView_1, avatarView_2, avatarView_3, avatarView_4]
    }

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
        let view = NSBundle.mainBundle().loadNibNamed(String(ParticipantsView), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    private func setup() {
        let screenWidth = UIScreen.mainWidth
        if screenWidth == 320 {
            avatarStackView.spacing = 5
        } else {
            avatarStackView.spacing = 8
        }
    }

}

// MARK:- ViewModelBinldable
extension ParticipantsView: ViewModelBindable {
    func bind() {
        viewModel
            .avatars
            .asDriver()
            .driveNext { [weak self] (avatars: [Avatarable]) in
                guard let strongSelf = self else { return }
                let participantAvatarViewModels = avatars.map { (avatar: Avatarable) -> ParticipantAvatarViewModel in
                    return ParticipantAvatarViewModel(avatar: Variable(avatar))
                }

                for (i, e) in strongSelf.avatarViews.enumerate() {
                    if let participantAvatarViewModel = participantAvatarViewModels[safe:i] {
                        e.viewModel = participantAvatarViewModel
                        e.hidden = false
                    } else {
                        e.hidden = true
                    }
                }

                if participantAvatarViewModels.count < 6 {
                    self?.restOfAvatarsView.hidden = true
                    if participantAvatarViewModels.count < 5 {
                        self?.avatarView_4.hidden = true
                    } else {
                        self?.avatarView_4.hidden = false
                    }
                } else {
                    self?.avatarView_4.hidden = true
                    self?.restOfAvatarsView.hidden = false
                    self?.restOfAvatarsLabel.text = "+\(String(participantAvatarViewModels.count - 4))"
                    UIView.animateWithDuration(0.3, animations: {
                        self?.restOfAvatarsView.alpha = 1
                    })
                }
            }.addDisposableTo(disposeBag)
    }
}
