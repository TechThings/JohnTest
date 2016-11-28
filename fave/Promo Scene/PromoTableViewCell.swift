//
//  PromoTableViewCell.swift
//  KFIT
//
//  Created by Nazih Shoura on 08/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PromoTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: PromoTableViewCellViewModel!

    // MARK: @IBOutlet private
    @IBOutlet weak private var expiresOnLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!

    // MARK: @IBOutlet internal
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var promoConditionLabel: UILabel!
    @IBOutlet weak var promoDescriptionLabel: UILabel!
    @IBOutlet weak var promoCodeLabel: KFITLabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var firstTimeUserOnlyTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstTimeUserOnlyContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var amountView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func setup() {
        cardView.layer.cornerRadius = 3
        configurePrivateLabelsText()
    }

    func configurePrivateLabelsText() {
        expiresOnLabel.text = NSLocalizedString("expires_on", comment: "")
        amountLabel.text = NSLocalizedString("amount", comment: "")
        promoConditionLabel.text = NSLocalizedString("promo_code_first_time_text", comment: "")
    }

    @IBAction func promoCardViewDidTapped(sender: AnyObject) {

    }

}

extension PromoTableViewCell : ViewModelBindable {
    func bind() {
        viewModel
            .expireDate
            .asDriver()
            .drive(expiryDateLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .promoCode
            .asDriver()
            .drive(promoCodeLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .hideConditionLabel
            .asDriver()
            .driveNext { [weak self] (hideConditionLabel: Bool) in
                if hideConditionLabel {
                    self?.firstTimeUserOnlyContainerViewHeightConstraint.constant = 0
                    self?.firstTimeUserOnlyTopConstraint.constant = 0
                    self?.layoutIfNeeded()
                    self?.setNeedsLayout()
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .discountDescription
            .asDriver()
            .drive(promoDescriptionLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .hideAmount
            .asDriver()
            .drive(amountView.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .discount
            .asDriver()
            .drive(discount.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

    }
}
