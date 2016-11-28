//
//  GuestViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 15/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class GuestViewController: ViewController {

    @IBAction func continueButtonDidTap(sender: AnyObject) {
        let vm = EnterPhoneNumberViewControllerViewModel(enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality.LoginAGuestUser)
        let vc = EnterPhoneNumberViewController.build(vm)
        let nvc = RootNavigationController.build(RootNavigationViewModel())
        nvc.setViewControllers([vc], animated: false)
        self.presentViewController(nvc, animated: true, completion: nil)
    }

    // MARK:- IBOutletz

    @IBOutlet weak var textLabel: KFITLabel!
    @IBOutlet weak var continueButton: UIButton!

    // MARK:- ViewModel
    var viewModel: GuestViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }
}

// MARK:- ViewModelBinldable
extension GuestViewController: ViewModelBindable {
    func bind() {
        viewModel.continueButtonTitle.driveNext { [weak self] in
            self?.continueButton.setTitle($0, forState: .Normal)
            }.addDisposableTo(disposeBag)

        viewModel.text.drive(textLabel.rx_text).addDisposableTo(disposeBag)
        textLabel.lineSpacing = 2.3

        viewModel
            .userProvider
            .currentUser
            .asDriver()
            .filter {!$0.isGuest}
            .driveNext { [weak self] _ in
                let nvc = self?.navigationController
                let vc = MoreViewController.build(MoreViewModel())
                nvc?.popToRootViewControllerAnimated(true)
                nvc?.setViewControllers([vc], animated: false)
        }.addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable
extension GuestViewController: Buildable {
    final class func build(builder: GuestViewControllerViewModel) -> GuestViewController {
        let storyboard = UIStoryboard(name: "Guest", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(GuestViewController)) as! GuestViewController
        vc.viewModel = builder
        return vc
    }
}
