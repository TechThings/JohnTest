//
//  ViewController.swift
//  LoginViewController
//
//  Created by Thanh KFit on 6/30/16.
//  Copyright © 2016 Thanh KFit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RegisterViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var promoButton: UIButton!
    @IBOutlet weak var promoTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var topContinueButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: KFITLabel!

    // MARK: IBAction
    @IBAction func didTapHavePromoCodeButton(sender: AnyObject) {
        promoTextField.hidden = !promoTextField.hidden
        if promoTextField.hidden {
            viewModel.promoCode.value = ""
        }

        let title = promoTextField.hidden ? NSLocalizedString("getting_started_have_promo_code_text", comment: "") : NSLocalizedString("enter_promo_code", comment: "")
        let color = promoTextField.hidden ? UIColor(red:0.20, green:0.66, blue:0.82, alpha:1.0) : UIColor.blackColor()
        promoButton.setTitle(title, forState: UIControlState.Normal)
        promoButton.setTitleColor(color, forState: UIControlState.Normal)

        topContinueButtonConstraint.constant = promoTextField.hidden ? 15 : 65
    }

    // MARK:- ViewModel
    var viewModel: RegisterViewModel!

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.promoButton.setTitle(NSLocalizedString("getting_started_have_promo_code_text", comment: ""), forState: .Normal)
        self.continueButton.setTitle(NSLocalizedString("getting_started_continue_button_text", comment: ""), forState: .Normal)

        descriptionLabel.lineSpacing = 2.4

        nameTextField.layer.cornerRadius = 2
        nameTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        nameTextField.layer.borderWidth = 0.5

        emailTextField.layer.cornerRadius = 2
        emailTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        emailTextField.layer.borderWidth = 0.5

        promoTextField.layer.cornerRadius = 2
        promoTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        promoTextField.layer.borderWidth = 0.5

        continueButton.enabled = false
        continueButton.setBackgroundColor(UIColor(hexStringFast: "#F2A5C3"), forState: .Disabled)

        topContinueButtonConstraint.constant = 15

        promoTextField.hidden = true
        endEditingWhenTapOnBackground(true)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_ENTER_PROFILE_DETAILS)

        registerKeyboardNotification()

        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func registerKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(0.1, animations: { () -> Void in
            let bottomContinueButton = UIScreen.mainScreen().bounds.size.height - (self.continueButton.frame.origin.y + self.continueButton.frame.size.height + 20)
            self.bottom.constant = keyboardFrame.size.height - bottomContinueButton
        })
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottom.constant = 0
        })
    }
    @IBAction func didTapContinueButton(sender: AnyObject) {
        viewModel.requestAddPromoRegiseterUser()
    }
}

// MARK:- ViewModelBinldable
extension RegisterViewController: ViewModelBindable {
    func bind() {
        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive
            }
            .subscribeNext { [weak self] (navigationClosure: NavigationClosure) in
                guard let strongSelf = self else { return }
                navigationClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)

        viewModel
            .everythingValid
            .drive(continueButton.rx_enabled)
            .addDisposableTo(disposeBag)

        viewModel
            .nameLabelColor
            .driveNext { [weak self] in
                self?.nameLabel.textColor = $0
            }
            .addDisposableTo(disposeBag)

        viewModel
            .emailLabelColor
            .driveNext { [weak self] in
                self?.emailLabel.textColor = $0
            }
            .addDisposableTo(disposeBag)

        viewModel
            .nameInputBoarderColor
            .driveNext { [weak self] in
                self?.nameTextField.layer.borderColor = $0
            }
            .addDisposableTo(disposeBag)

        viewModel
            .emailInputBoarderColor
            .driveNext { [weak self] in
                self?.emailTextField.layer.borderColor = $0
            }
            .addDisposableTo(disposeBag)

        nameTextField
            .rx_text
            .skipWhile { $0.characters.count == 0 }
            .bindTo(viewModel.name)
            .addDisposableTo(disposeBag)

        emailTextField
            .rx_text
            .skipWhile { $0.characters.count == 0 }
            .bindTo(viewModel.email)
            .addDisposableTo(disposeBag)

        promoTextField
            .rx_text
            .bindTo(viewModel.promoCode)
            .addDisposableTo(disposeBag)

    }
}

extension RegisterViewController: Buildable {
    static func build(builder: RegisterViewModel) -> RegisterViewController {
        let registerStoryboard = UIStoryboard(name: "Register", bundle: nil)
        let registerViewController = registerStoryboard.instantiateViewControllerWithIdentifier(String(RegisterViewController)) as! RegisterViewController
        registerViewController.viewModel = builder
        return registerViewController
    }
}
