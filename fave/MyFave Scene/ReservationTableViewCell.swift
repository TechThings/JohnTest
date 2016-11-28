//
//  ReservationTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ReservationTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: ReservationViewModel!

    // MARK:- Constant

    // MARK:- IBOutlets

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var statusViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusNameLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var outletNameLabel: UILabel!

    @IBOutlet weak var timeSlotDayLabel: UILabel!
    @IBOutlet weak var timeSlotTimeLabel: UILabel!
    @IBOutlet weak var openVoucherView: UIView!
    @IBOutlet weak var openVoucherLabel: UILabel!

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        containerView.layer.cornerRadius = 3
    }
}

// MARK:- ViewModelBinldable
extension ReservationTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .statusViewHidden
            .drive(statusView.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .statusViewHidden
            .driveNext { [weak self] (statusViewHidden: Bool) in
                if statusViewHidden == true {
                    self?.statusViewHeightConstraint.constant = 0
                } else {
                    self?.statusViewHeightConstraint.constant = 35
                }
                    self?.layoutIfNeeded()
                    self?.setNeedsLayout()
        }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .statusColor
            .driveNext { [weak self] (color: UIColor) in
                self?.statusNameLabel.textColor = color
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .statusTitle
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (statusTitle) in
                self?.statusNameLabel.text = statusTitle
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.listingPhoto
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (value) in
                if let value = value {
                    self?.activityImageView.kf_setImageWithURL(
                        value
                        , placeholderImage: UIImage(named: "image-placeholder")
                        , optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                } else {
                    self?.activityImageView.image = UIImage(named: "image-placeholder")
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .listingName
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (listingName) in
                self?.activityNameLabel.text = listingName
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .companyName
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (companyName) in
                self?.companyNameLabel.text = companyName
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .outletName
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (outletName) in
                self?.outletNameLabel.text = outletName
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .timeSlotDay
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (timeSlotDay) in
                self?.timeSlotDayLabel.text = timeSlotDay
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .timeSlotTime
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (timeSlotTime) in
                self?.timeSlotTimeLabel.text = timeSlotTime
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .hideOpenVoucherView
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (hideOpenVoucherView) in
                self?.openVoucherView.hidden = hideOpenVoucherView
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .openVoucherText
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (openVoucherText) in
                self?.openVoucherLabel.text = openVoucherText
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}
