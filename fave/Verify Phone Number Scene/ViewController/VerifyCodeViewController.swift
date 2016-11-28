//
//  VerifyCodeViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class VerifyCodeViewController: ViewController, CodeInputViewDelegate {

    @IBOutlet weak var sendNewCodeButton: UIButton! {
        didSet {
            self.sendNewCodeButton.setTitle(NSLocalizedString("verify_send_new_code_text", comment: ""), forState: .Normal)
        }
    }
    // MARK:- IBOutlet
    @IBOutlet weak var descriptionLabel: KFITLabel!
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            self.submitButton.setTitle(NSLocalizedString("getting_started_continue_button_text", comment: ""), forState: .Normal)
            self.submitButtonBackgroundColor = submitButton.backgroundColor
            submitButton.enabled = false
        }
    }
    @IBOutlet weak var codeInputLabelView: UIView!

    @IBAction func submitButtonDidTap(sender: AnyObject) {
        viewModel.submitButtonDidTap.onNext(())
    }

    @IBAction func resendButtonDidTap(sender: AnyObject) {
        viewModel.resendButtonDidTap.onNext(())
    }

    // MARK:- ViewModel
    var viewModel: VerifyCodeViewControllerViewModel!
    let codeInputBoxes = CodeInputView(frame: CGRect(x:(UIScreen.mainWidth-40-215)/2, y: 0, width: 215, height:50))
    var submitButtonBackgroundColor: UIColor!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.title = NSLocalizedString("verify_title_text", comment: "")
        descriptionLabel.lineSpacing = 2.3

        codeInputBoxes.delegate = self
        codeInputBoxes.tag = 17
        codeInputLabelView.addSubview(codeInputBoxes)

        #if DEBUG
            configureLongPressButton()
        #endif
    }

    func configureLongPressButton() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.submitButton.addGestureRecognizer(longPress)
    }
    func longPress(guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizerState.Began {
            viewModel.submitButtonDidLogPress.onNext(())
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())
        codeInputBoxes.becomeFirstResponder()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_PHONE_VERIFICATION_ENTER_CODE)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        if code.characters.count == 4 {
            submitButton.backgroundColor = UIColor.favePink()
            submitButton.enabled = true
            viewModel.code.value = code
        } else {
            submitButton.backgroundColor = self.submitButtonBackgroundColor
            submitButton.enabled = false
        }
    }

    func codeInputView(codeInputView: CodeInputView, isCompleted: Bool) {
        if isCompleted {
            submitButton.backgroundColor = UIColor.favePink()
            submitButton.enabled = true
        } else {
            submitButton.backgroundColor = self.submitButtonBackgroundColor
            submitButton.enabled = false
        }
    }

    func appBecomeActive(notification: NSNotification) {
        codeInputBoxes.becomeFirstResponder()
    }
}

// MARK:- ViewModelBinldable
extension VerifyCodeViewController: ViewModelBindable {
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

    }
}

// MARK:- Buildable
extension VerifyCodeViewController: Buildable {
    final class func build(builder: VerifyCodeViewControllerViewModel) -> VerifyCodeViewController {
        let storyboard = UIStoryboard(name: "VerifyCode", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.VerifyCodeViewController) as! VerifyCodeViewController
        vc.viewModel = builder
        return vc
    }
}
