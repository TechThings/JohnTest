//
//  ChannelInvitationCollectionViewCell.swift
//  FAVE
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ChannelInvitationCollectionViewCell: CollectionViewCell {

    // MARK:- ViewModel
    var viewModel: ChannelInvitationCollectionViewCellViewModel! {
        didSet {
            bind()
        }
    }

    // MARK:- IBOutlets
    @IBOutlet weak var participantsView: ParticipantsView!
    @IBOutlet weak var invitationTitleLabel: KFITLabel!
    @IBOutlet weak var outletNameLabel: UILabel!
    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var maybeLabel: UILabel!
    @IBOutlet weak var listingNameLabel: UILabel!
    @IBOutlet weak var interestedToJoinLabel: UILabel!

    // MARK:- IBAction
    @IBAction func yesButtonDidTap(sender: UIButton) {
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "yes", screenName: screenName.SCREEN_CHAT_HOME)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)
        viewModel.yesButtonDidTap.onNext(())
    }
    @IBAction func noButtonDidTap(sender: UIButton) {
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "no", screenName: screenName.SCREEN_CHAT_HOME)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)
        viewModel.noButtonDidTap.onNext(())
    }
    @IBAction func maybeButtonDidTap(sender: UIButton) {
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "maybe", screenName: screenName.SCREEN_CHAT_HOME)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)
        viewModel.maybeButtonDidTap.onNext(())
    }

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable
extension ChannelInvitationCollectionViewCell: ViewModelBindable {
    func bind() {
        //viewModel.yesStatic.drive(yesLabel.rx_text).addDisposableTo(disposeBag)
        //viewModel.noStatic.drive(noLabel.rx_text).addDisposableTo(disposeBag)
        //viewModel.maybeStatic.drive(maybeLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.interestedToJoinStatic.drive(interestedToJoinLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.originalPrice.drive(originalPriceLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.finalPrice.drive(finalPriceLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.outletName.drive(outletNameLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.partnerName.drive(partnerNameLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.invitationTitle.drive(invitationTitleLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.listingName.drive(listingNameLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel
            .channel
            .asDriver()
            .driveNext { [weak self] (channel: Channel) in
                let avatars: [Avatarable] = channel.chatParticipants.map { (chatParticipant: ChatParticipant) -> Avatarable in chatParticipant as Avatarable}
                self?.participantsView.viewModel = ParticipantsViewModel(avatars: Variable(avatars))
                self?.participantsView.stackViewCenterXConstraint.priority = 999
                self?.participantsView.stackViewLeadingConstraint.priority = 250
                self?.participantsView.stackViewLeadingConstraint.active = false
        }.addDisposableTo(rx_reusableDisposeBag)
        invitationTitleLabel.lineSpacing = 2.3
    }
}
