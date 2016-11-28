//
//  AddPaymentMethodTableViewCell.swift
//  FAVE
//
//  Created by Ranjeet on 23/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AddPaymentMethodTableViewCell: TableViewCell {

    var viewModel: AddPaymentMethodTableViewCellViewModel! {
        didSet { bind() }
    }

    // MARK:- @IBOutlet 4854991901022730
    @IBOutlet weak var backgroudView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var addCardButton: UIButton!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var cvvNumberLabel: UILabel!

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var cardNumberView: UIView!
    @IBOutlet weak var expiryDateView: UIView!
    @IBOutlet weak var cvvView: UIView!

    private var cardTypeImageView: UIImageView?
    private var responsers = [UITextField]()

    @IBAction func addCardButtonDidTap(sender: AnyObject) {
        viewModel.addCardButtonDidTap.onNext()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(String(AddPaymentMethodTableViewCell), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {

        self.addCardButton.setTitle(NSLocalizedString("add_contacts_enable", comment: ""), forState: .Normal)

        responsers = [nameTextField, cardNumberTextField, expiryDateTextField, cvvTextField]

        let cardImageWidth = UIImage(named:"Visa")!.size.width
        self.cardTypeImageView = UIImageView(frame: CGRectMake(0, 0, cardImageWidth,self.cardNumberTextField.frame.size.height - 4))
        self.cardTypeImageView?.contentMode = .ScaleAspectFit
        self.cardNumberTextField.rightView = self.cardTypeImageView
        self.cardNumberTextField.rightViewMode = UITextFieldViewMode.Always

        self.backgroudView.roundedView(3.0, borderColor: UIColor(hexStringFast: "#D8DEE2"))
        self.backgroudView.clipsToBounds = true
    }
}

// MARK:- ViewModelBinldable
extension AddPaymentMethodTableViewCell: ViewModelBindable {
    func bind() {
        // Move the focus to cardNumberTextField when the user hit "return" on nameTextField
        nameTextField
            .rx_controlEvent(UIControlEvents.EditingDidEndOnExit)
            .subscribeNext {
                self.cardNumberTextField.becomeFirstResponder()
            }.addDisposableTo(self.rx_reusableDisposeBag)

        // This is changing the responser which is part of the UI, hence the logic here is justified
        viewModel
            .moveToNextReponserTrigger
            .driveNext { [weak self] _ in
                guard let responsers = self?.responsers else { return }
                for (index, responser) in responsers.enumerate() {
                    if responser.isFirstResponder() {
                        responsers[safe: index + 1]?.becomeFirstResponder()
                        break
                    }
                }
            }
            .addDisposableTo(rx_reusableDisposeBag)

        nameTextField
            .rx_text
            .bindTo(viewModel.name)
            .addDisposableTo(rx_reusableDisposeBag)

        cardNumberTextField
            .rx_text
            .bindTo(viewModel.tempCardNumber)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .formatedCardNumber
            .drive(cardNumberTextField.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .formatedCardExpiryDate
            .drive(expiryDateTextField.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        expiryDateTextField
            .rx_text
            .bindTo(viewModel.tempCardExpiryDate)
            .addDisposableTo(rx_reusableDisposeBag)

        cvvTextField
            .rx_text
            .bindTo(viewModel.tempCVV)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .formatedCVV
            .drive(cvvTextField.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .addCardButtonEnabled
            .drive(addCardButton.rx_enabled)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .addCardButtonEnabled
            .driveNext { [weak self] (addCardButtonEnabled: Bool) in
                if addCardButtonEnabled {
                    self?.addCardButton.backgroundColor = UIColor.favePink()
                } else {
                    self?.addCardButton.backgroundColor = UIColor(hexStringFast: "#CBD3D8")
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .nameValidated
            .driveNext { [weak self] (nameValidated: Bool) in
                if nameValidated {
                    self?.nameLabel.textColor = UIColor.faveDarkGray()
                    self?.nameView.backgroundColor = UIColor.whiteColor()
                } else {
                    self?.nameLabel.textColor = UIColor.redColor()
                    self?.nameView.backgroundColor = UIColor.faveErrorRed()
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .cardNumberValidated
            .driveNext { [weak self] (cardNumberValidated: Bool) in
                if cardNumberValidated {
                    self?.cardNumberLabel.textColor = UIColor.faveDarkGray()
                    self?.cardNumberView.backgroundColor = UIColor.whiteColor()
                } else {
                    self?.cardNumberLabel.textColor = UIColor.redColor()
                    self?.cardNumberView.backgroundColor = UIColor.faveErrorRed()
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .expiryDateValidated
            .driveNext { [weak self] (expiryDateValidated: Bool) in
                if expiryDateValidated {
                    self?.expiryDateLabel.textColor = UIColor.faveDarkGray()
                    self?.expiryDateView.backgroundColor = UIColor.whiteColor()
                } else {
                    self?.expiryDateLabel.textColor = UIColor.redColor()
                    self?.expiryDateView.backgroundColor = UIColor.faveErrorRed()
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .cvvNumberValidated
            .driveNext { [weak self] (cvvNumberValidated: Bool) in
                if cvvNumberValidated {
                    self?.cvvNumberLabel.textColor = UIColor.faveDarkGray()
                    self?.cvvView.backgroundColor = UIColor.whiteColor()
                } else {
                    self?.cvvNumberLabel.textColor = UIColor.redColor()
                    self?.cvvView.backgroundColor = UIColor.faveErrorRed()
                }

            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .cardImage
            .driveNext { [weak self] (cardImage: UIImage?) in
                self?.cardTypeImageView?.image = cardImage
            }
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
