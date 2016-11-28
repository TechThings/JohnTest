//
//  LocationPermissionViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 06/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

final class LocationPermissionViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var descriptionLabel: KFITLabel!

    // MARK:- ViewModel
    var viewModel: LocationPermissionViewModel!

    // MARK:- Variable
    var permissionRequestPresented = false

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.lineSpacing = 2.5
        self.okButton.setTitle(NSLocalizedString("location_permission_prompt_okay_button_text", comment:""), forState: .Normal)
        self.cancelButton.setTitle(NSLocalizedString("location_permission_prompt_not_now_button_text", comment:""), forState: .Normal)
        // Whenever we receive a new permission. call didFinishAskingPermission(
        viewModel
            .locationService
            .locationPermission
            .asObservable()
            .skip(1) // We are not interested in the current Variable value
            .subscribeNext {
                [weak self] _ in
                self?.didFinishAskingPermission()
            }.addDisposableTo(disposeBag)

        bind()

        self.navigationController?.navigationBar.hidden = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_LOCATION_PERMISSION)
    }

    @IBAction func didTapOKButton(sender: AnyObject) {
        viewModel.app.update(isCompletedRequestEnableLocation: true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appWillResignActive), name: UIApplicationWillResignActiveNotification, object: nil)

        if self.viewModel.locationService.locationPermission.value == .NotDetermined {
            self.viewModel.locationService.requestLocationPermission(.WhenInUse)
        } else if !(self.viewModel.locationService.locationPermission.value == CLAuthorizationStatus.AuthorizedAlways
            || self.viewModel.locationService.locationPermission.value == CLAuthorizationStatus.AuthorizedWhenInUse) {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }

        self.performSelector(#selector(self.checkPermissionReqestPresented), withObject: nil, afterDelay: 1)
    }

    @IBAction func didTapCancelButton(sender: AnyObject) {
        showNextViewController()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

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
        if self.viewModel.locationService.locationPermission.value == .AuthorizedAlways
            || self.viewModel.locationService.locationPermission.value == .AuthorizedWhenInUse {

            viewModel.cityProvider.refresh()

            viewModel
                .cityProvider
                .currentCity
                .asObservable()
                .filterNil()
                .take(1)
                .observeOn(MainScheduler.instance)
                .subscribeNext { [weak self] _ in
                    self?.showNextViewController()
                }.addDisposableTo(disposeBag)

            showNextViewController()

        } else {
            showNextViewController()
        }
    }

    @objc
    func showNextViewController() {
        guard viewModel.cityProvider.currentCity.value != nil else {
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

// MARK:- ViewModelBinldable
extension LocationPermissionViewController: ViewModelBindable {
    func bind() {}
}

// MARK:- Buildable
extension LocationPermissionViewController: Buildable {
    static func build(builder: LocationPermissionViewModel) -> LocationPermissionViewController {
        let storyboard = UIStoryboard(name: "LocationPermission", bundle: nil)
        let locationPermissionViewController = storyboard.instantiateViewControllerWithIdentifier(String(LocationPermissionViewController)) as! LocationPermissionViewController
        locationPermissionViewController.viewModel = builder
        return locationPermissionViewController
    }
}
