//
//  PromoAddedView.swift
//  KFIT
//
//  Created by Nazih Shoura on 08/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class PromoAddedView: UIView {

    // MARK: @IBOutlet private
    @IBOutlet weak private var promocodeSuccessfullyAddedLabel: UILabel!
    @IBOutlet weak private var expiresOnLabel: UILabel!
    @IBOutlet weak private var expiresOnWithAmountLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var dismissButton: UIButton!
    @IBOutlet weak private var firstTimeUserOnlyContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var expiryDateContainerView: UIView!

    // MARK: @IBOutlet internal
    @IBOutlet weak var promoCodeLabel: UILabel!
    @IBOutlet weak var promoDescriptionLabel: UILabel!
    @IBOutlet weak var promoMarketingDescriptionLabel: UILabel!
    @IBOutlet weak var promoConditionLabel: UILabel!
    @IBOutlet weak var promoExpiryDateLabel: UILabel!
    @IBOutlet weak var promoExpiryDateWithAmountLabel: UILabel!

    @IBOutlet weak var promoAmoutLabel: UILabel!
    @IBOutlet weak var promoCodeSuccessfullyAddedViewHieghtConstraint: NSLayoutConstraint!

    // MARK: @IBAction internal
    @IBAction func dismissButtonDidTab(sender: AnyObject) {
        delegate?.promoAddedViewDismissButtonDidTab(self)
    }

    // MARK: properties internal
    weak var delegate: PromoAddedViewDelegate?

    // MARK: initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.load()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.load()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(String(PromoAddedView), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        setup()

    }

    private func setup() {
        layer.cornerRadius = 2
        layer.masksToBounds = true
        configurePrivateLabelsText()
        expiryDateContainerView.hidden = true
    }

    func removeAmount() {
        expiryDateContainerView.hidden = false
    }

    func removePromoConditionLabel() {
        firstTimeUserOnlyContainerViewHeightConstraint.constant = 0
    }

    func configurePrivateLabelsText() {
        promocodeSuccessfullyAddedLabel.text = NSLocalizedString("promo_code_successfully_added", comment: "")
        expiresOnLabel.text = NSLocalizedString("expires_on", comment: "")
        expiresOnWithAmountLabel.text = NSLocalizedString("expires_on", comment: "")
        amountLabel.text = NSLocalizedString("amount", comment: "")
        dismissButton.setTitle(NSLocalizedString("chat_button_on_boarding_action_text", comment: ""), forState: .Normal)
    }

}

@objc
protocol PromoAddedViewDelegate {
    func promoAddedViewDismissButtonDidTab(PromoAddedView: PromoAddedView)
}
