//
//  PromoHeaderTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

@objc protocol PromoHeaderTableViewCellDelegate {
    func promoDidApplyCode(code: String)
}

final class PromoHeaderTableViewCell: UITableViewCell {

    // MARK: @IBOutlet internal
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var promoCodeTextField: InsetTextField!

    // MARK: @IBAction internal
    @IBAction func applyButtonDidTap(sender: UIButton) {
        if let delegate = delegate {
            delegate.promoDidApplyCode(promoCodeTextField.text!.uppercaseString)
        }
    }

    // MARK: Properties internal
    weak var delegate: PromoHeaderTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        // Initialization code
    }

    private func setup() {
        promoCodeTextField.delegate = self
        promoCodeTextField.addTarget(self, action: #selector(promoCodeTextFieldChanged), forControlEvents: .EditingChanged)
        applyButton.titleLabel?.textAlignment = NSTextAlignment.Center
        updateApplyButton()

        promoCodeTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        promoCodeTextField.layer.borderWidth = 0.5
        promoCodeTextField.layer.cornerRadius = 3
        applyButton.layer.cornerRadius = 3
        configurePrivateLabelsText()
    }

    func configurePrivateLabelsText() {
        promoCodeTextField.placeholder = NSLocalizedString("enter_promo_code", comment: "")
        applyButton.setTitle(NSLocalizedString("filter_apply_text", comment: ""), forState: .Normal)
    }

    func promoCodeTextFieldChanged() {
        updateApplyButton()
    }

    func updateApplyButton() {
        let promoCodeText = promoCodeTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if promoCodeText?.characters.count > 0 {
            applyButton.enabled = true
            applyButton.backgroundColor = UIColor.favePink()
        } else {
            applyButton.enabled = false
            applyButton.backgroundColor = UIColor.lightGrayColor()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension PromoHeaderTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let promoCodeText = promoCodeTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if promoCodeText?.characters.count > 0 {
            delegate?.promoDidApplyCode(textField.text!)
        }
        return true
    }
}
