//
//  ChannelView.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelView: View {

    private var compositeDisposable = CompositeDisposable()

    // MARK:- ViewModel
    var viewModel: ChannelViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var offerDescriptionLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: KFITLabel!
    @IBOutlet weak var unreadMessagesLabel: UILabel!
    @IBOutlet weak var unreadMessagesView: UIView!
    @IBOutlet weak var participantsView: ParticipantsView!

    @IBAction func openChatButtonDidTap(sender: UIButton) {

        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "view_chat", screenName: screenName.SCREEN_CHAT_HOME)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

        viewModel.openChatButtonDidTap.onNext(())
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
        unreadMessagesView.layer.cornerRadius = unreadMessagesView.frame.size.height/2
    }

    func prepareForCellReuse() {
        self.compositeDisposable.dispose()
        self.compositeDisposable = CompositeDisposable()
    }
}

// MARK:- ViewModelBinldable
extension ChannelView: ViewModelBindable {
    func bind() {
        compositeDisposable.addDisposable(
            viewModel
                .unreadMessages
                .drive(unreadMessagesLabel.rx_text))

        compositeDisposable.addDisposable(
            viewModel
                .timeStamp
                .drive(timeStampLabel.rx_text))

        compositeDisposable.addDisposable(
            viewModel
                .channelTitle
                .drive(channelTitleLabel.rx_text))

        compositeDisposable.addDisposable(
            viewModel
                .offerDescription
                .drive(offerDescriptionLabel.rx_text))

        compositeDisposable.addDisposable(
            viewModel
                .unreadMessagesHidden
                .drive(unreadMessagesView.rx_hidden))

        compositeDisposable.addDisposable(
            viewModel
                .channel
                .asDriver()
                .driveNext { [weak self] (channel: Channel) in
                    let avatars: [Avatarable] = channel.chatParticipants.map { (chatParticipant: ChatParticipant) -> Avatarable in chatParticipant as Avatarable}
                    self?.participantsView.viewModel = ParticipantsViewModel(avatars: Variable(avatars))
                    self?.participantsView.stackViewCenterXConstraint.priority = 250
                    self?.participantsView.stackViewCenterXConstraint.active = false
                    self?.participantsView.stackViewLeadingConstraint.priority = 999
                    self?.participantsView.stackViewLeadingConstraint.constant = 0
            })

        channelTitleLabel.lineSpacing = 2.2
        channelTitleLabel.textAlignment = .Left
    }
}
