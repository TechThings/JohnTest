//
//  EnterPhoneNumberViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class EnterPhoneNumberViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var topLabel: KFITLabel!
    @IBOutlet weak var bottomLabel: KFITLabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var selectCountryCodeButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var countryCallingCodeLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!

    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBAction func selectCountryCodeButtonDidTap(sender: AnyObject) {
        viewModel.selectCountryCodeButtonDidTap.onNext(())
    }

    @IBAction func verifyButtonDidTap(sender: AnyObject) {
        viewModel.verifyButtonDidTap.onNext(())
    }

    @IBAction func dismissButtonDidTap(sender: AnyObject) {
        viewModel.dismissButtonDidTap.onNext(())
    }

    // MARK:- ViewModel
    var viewModel: EnterPhoneNumberViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        self.title = NSLocalizedString("signup_title_text", comment: "")
        topLabel.lineSpacing = 2.3
        bottomLabel.lineSpacing = 2.3

        switch viewModel.enterPhoneNumberViewControllerViewModelFunctionality {
        case .LoginAGuestUser:
            self.navigationItem.rightBarButtonItem?.tintColor = .blackColor()
            self.navigationItem.rightBarButtonItem?.enabled = true
        case .LoginANewUser:
            self.navigationItem.rightBarButtonItem?.tintColor = .clearColor()
            self.navigationItem.rightBarButtonItem?.enabled = false
        }

        #if DEBUG
            configureLongPressButton()
        #endif
    }

    func configureLongPressButton() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.verifyButton.addGestureRecognizer(longPress)
    }
    func longPress(guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizerState.Began {
            viewModel.verifyButtonDidLogPress.onNext(())
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        phoneNumberTextField.becomeFirstResponder()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_PHONE_VERIFICATION_ENTER_NUMBER)

    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
}

// MARK:- ViewModelBinldable
extension EnterPhoneNumberViewController: ViewModelBindable {
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

        phoneNumberTextField
            .rx_text
            .bindTo(viewModel.phoneNumber)
            .addDisposableTo(disposeBag)

        viewModel.countryCallingCode.drive(countryCallingCodeLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.countryName.drive(countryNameLabel.rx_text).addDisposableTo(disposeBag)

        viewModel
            .verifyButtonEnabled
            .drive(verifyButton.rx_enabled)
            .addDisposableTo(disposeBag)

        viewModel
            .verifyButtonEnabled
            .driveNext { [weak self] (verifyButtonEnabled: Bool) in
            if verifyButtonEnabled {
                self?.verifyButton.backgroundColor = UIColor.favePink()
            } else {
                self?.verifyButton.backgroundColor = UIColor(white: 1, alpha: 0.7)
            }
        }.addDisposableTo(disposeBag)

    }
}

// MARK:- Buildable
extension EnterPhoneNumberViewController: Buildable {
    final class func build(builder: EnterPhoneNumberViewControllerViewModel) -> EnterPhoneNumberViewController {
        let storyboard = UIStoryboard(name: "EnterPhoneNumber", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.EnterPhoneNumberViewController) as! EnterPhoneNumberViewController
        vc.viewModel = builder
        return vc
    }
}
