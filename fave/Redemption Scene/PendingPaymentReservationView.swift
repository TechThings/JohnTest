//
//  PendingPaymentReservationView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import DeviceKit

final class PendingPaymentReservationView: View {

    // MARK:- ViewModel
    var viewModel: PendingPaymentReservationViewModel! {
        didSet { bind() }
    }

    // MARK:- @IBOutlet
    @IBOutlet weak var appImageView: UIImageView!

    @IBOutlet weak var cardWrapView: UIView!
    @IBOutlet weak var avatarWrapView: AvatarView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var pendingPaymentTitleLabel: KFITLabel!
    @IBOutlet weak var pendingPaymentDescriptionLabel: KFITLabel!
    @IBOutlet weak var payButtonTitleLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!

    @IBOutlet weak var payButtonContainerView: UIView!

    // MARK:- @IBAction
    @IBAction func payButtonDidTap(sender: AnyObject) {
        viewModel.payButtonDidTap.onNext(())
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

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(String(PendingPaymentReservationView), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
        setup()
    }

    func setup() {
        cardWrapView.layer.cornerRadius = 3
        avatarWrapView.layer.cornerRadius = 30
        avatarWrapView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarWrapView.layer.borderWidth = 2

    }
}

// MARK:- ViewModelBinldable
extension PendingPaymentReservationView: ViewModelBindable {
    func bind() {

        // Dynamic
        viewModel
            .profilePictureViewModel
            .asDriver()
            .driveNext { [weak self] (profilePictureViewModel) in
                self?.avatarWrapView.viewModel = profilePictureViewModel
            }.addDisposableTo(disposeBag)

        viewModel
            .userName
            .drive(userNameLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .quantity
            .drive(quantityLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .pendingPaymentTitle
            .drive(pendingPaymentTitleLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .pendingPaymentDescription
            .drive(pendingPaymentDescriptionLabel.rx_text)
            .addDisposableTo(disposeBag)

        pendingPaymentDescriptionLabel.lineSpacing = 2.3

        viewModel
            .payButtonTitle
            .drive(payButtonTitleLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .payNowUserHidden
            .drive(payButtonContainerView.rx_hidden)
            .addDisposableTo(disposeBag)

        viewModel.appImage
            .driveNext {[weak self] (image) in
                guard let stronSelf = self else { return }
                stronSelf.appImageView.image = image
            }.addDisposableTo(disposeBag)

        if viewModel.reservation.listingDetails.primaryPaymentGateway == .Adyen {
            self.payButtonContainerView.hidden = true

        }
    }
}
