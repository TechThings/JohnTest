//
//  NotificationPermissionViewController.swift
//  FAVE
//
//  Created by Kevin Mun on 23/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
final class NotificationPermissionViewController: ViewController {
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: KFITLabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var permissionRequestPresented = false

    var viewModel: NotificationPermissionViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.lineSpacing = 2.5
        self.navigationController?.navigationBar.hidden = true
        self.okButton.setTitle(NSLocalizedString("location_permission_prompt_okay_button_text", comment:""), forState: .Normal)
        self.cancelButton.setTitle(NSLocalizedString("location_permission_prompt_not_now_button_text", comment:""), forState: .Normal)

    }

    @IBAction func didTapOKButton(sender: AnyObject) {
        viewModel.app.update(isCompletedRequestEnableNotification: true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appWillResignActive), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didFinishAskingPermission), name: UIApplicationDidBecomeActiveNotification, object: nil)
        self.viewModel.app.registerUserNotification()
        self.viewModel.app.registerRemoteNotification()
        self.performSelector(#selector(self.checkPermissionReqestPresented), withObject: nil, afterDelay: 1)
    }

    @IBAction func didTapCancelButton(sender: AnyObject) {
        let vc = LocationPermissionViewController.build(LocationPermissionViewModel())
        self.navigationController?.setViewControllers([vc], animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_PUSH_NOTIFICATION_PERMISSION)
    }

    @objc
    func appWillResignActive() {
        permissionRequestPresented = true
    }

    @objc
    func checkPermissionReqestPresented() {
        if !permissionRequestPresented {
            didFinishAskingPermission()
        }
    }

    @objc
    func didFinishAskingPermission() {

        if (viewModel.locationService.isAllowedLocationPermission.value == false) {
            if viewModel.app.isCompletedRequestEnableLocation == false {
                let vc = LocationPermissionViewController.build(LocationPermissionViewModel())
                self.navigationController?.setViewControllers([vc], animated: true)
                return
            }
        }

        guard self.viewModel.cityProvider.currentCity.value != nil else {
            let vc = CitiesViewController.build(CitiesViewModel())
            self.navigationController?.setViewControllers([vc], animated: true)
            return
        }

        guard self.viewModel.userProvider.currentUser.value.userStatus == UserStatus.Registered
            || self.viewModel.userProvider.currentUser.value.userStatus == UserStatus.Guest else {
            let vc = RegisterViewController.build(RegisterViewModel())
            self.navigationController?.setViewControllers([vc], animated: true)
            return
        }
        guard navigationController?.presentingViewController == nil else {
            navigationController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        let rootTabBarController = RootTabBarController.build(RootTabBarViewModel(setAsRoot: true))
        navigationController?.presentViewController(rootTabBarController, animated: true, completion: nil)
    }
}

// MARK:- Buildable
extension NotificationPermissionViewController: Buildable {
    final class func build(builder: NotificationPermissionViewModel) -> NotificationPermissionViewController {
        let storyboard = UIStoryboard(name: "NotificationPermission", bundle: nil)
        let notificationPermissionViewController = storyboard.instantiateViewControllerWithIdentifier(String(NotificationPermissionViewController)) as! NotificationPermissionViewController
        notificationPermissionViewController.viewModel = builder
        return notificationPermissionViewController
    }
}
