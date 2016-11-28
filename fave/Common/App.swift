//
//  App.swift
//
//  Created by Nazih Shoura on 22/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SwiftLoader
import AdSupport.ASIdentifierManager

protocol AppType {
    var logoutSignal: PublishSubject<()> {get}
    var mode: Mode {get set}
    var keys: Keys {get}
    func appEntryViewController() -> UIViewController
    var networkService: NetworkService? {get}
    func registerUserNotification()
    func registerRemoteNotification()
    var appVersion: String {get}
    var buildNumber: Int {get}
    var currentDeviceModel: String {get}
    var currentDeviceSystemVersion: String {get}
    var activityIndicator: ActivityIndicator {get}
    var cityProvider: CityProvider? {get}
    var lightHouseService: LightHouseService? {get}
    func update(mode mode: Mode)
    func update(isCompletedRequestEnableLocation isCompletedRequestEnableLocation: Bool)
    func update(isCompletedRequestEnableNotification isCompletedRequestEnableNotification: Bool)

    // Must call before using App
    func setNetworkSevice(networkService: NetworkService)
    func setCityProvider(cityProvider: CityProvider)
    func setLightHouseService(lightHouseService: LightHouseService)

    func isRegisteredForRemoteNotifications() -> Bool
    var isCompletedRequestEnableLocation: Bool {get set}
    var isCompletedRequestEnableNotification: Bool {get set}
}

final class App: AppType {

    var mode: Mode {
        didSet {
            App.cache(mode: mode)
        }
    }

    func update(mode mode: Mode) {
        self.mode = mode
    }

    var isCompletedRequestEnableLocation: Bool {
        didSet {
            App.cache(isCompletedRequestEnableLocation: isCompletedRequestEnableLocation)
        }
    }

    func update(isCompletedRequestEnableLocation isCompletedRequestEnableLocation: Bool) {
        self.isCompletedRequestEnableLocation = isCompletedRequestEnableLocation
    }

    var isCompletedRequestEnableNotification: Bool {
        didSet {
            App.cache(isCompletedRequestEnableNotification: isCompletedRequestEnableNotification)
        }
    }

    func update(isCompletedRequestEnableNotification isCompletedRequestEnableNotification: Bool) {
        self.isCompletedRequestEnableNotification = isCompletedRequestEnableNotification
    }

    var networkService: NetworkService?
    func setNetworkSevice(networkService: NetworkService = networkServiceDefault) {
        self.networkService = networkService
    }

    var cityProvider: CityProvider?
    func setCityProvider(cityProvider: CityProvider = cityProviderDefault) {
        self.cityProvider = cityProvider
    }

    var lightHouseService: LightHouseService?
    func setLightHouseService(lightHouseService: LightHouseService = lightHouseServiceDefault) {
        self.lightHouseService = lightHouseService
    }

    let logoutSignal = PublishSubject<()>()

    let appVersion: String
    let buildNumber: Int
    let currentDeviceModel: String
    let currentDeviceSystemVersion: String
    let advertisingId: String

    let activityIndicator = ActivityIndicator()

    var disposeBag = DisposeBag()
    // Constant
    let keys = Keys()

    init() {
        let infoDict = NSBundle.mainBundle().infoDictionary
        self.appVersion = "\(infoDict!["CFBundleShortVersionString"]!)"
        self.buildNumber = Int("\(infoDict!["CFBundleVersion"]!)")!
        self.currentDeviceModel = UIDevice.currentDevice().model
        self.currentDeviceSystemVersion = UIDevice.currentDevice().systemVersion
        self.advertisingId = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString

        activityIndicator.drive(UIApplication.sharedApplication().rx_networkActivityIndicatorVisible).addDisposableTo(disposeBag)
        activityIndicator.driveNext { (active: Bool) -> () in
            guard UIApplication.sharedApplication().keyWindow != nil else {
                return
            }
            if active { SwiftLoader.show(animated: true) } else { SwiftLoader.hide() }
            }.addDisposableTo(disposeBag)

        #if DEBUG
        self.mode = App.loadCacheForMode()
        #else
        self.mode = Mode.Release
        #endif

        self.isCompletedRequestEnableLocation = App.loadisCompletedRequestEnableLocation()
        self.isCompletedRequestEnableNotification = App.loadisCompletedRequestEnableNotification()
    }

    func appEntryViewController() -> UIViewController {

        guard networkService!.sessionExist else {
            let vm = OnboardingViewModel()
            let vc = OnboardingViewController.build(vm)
            let nvc = RootNavigationController.build(RootNavigationViewModel())
            nvc.setViewControllers([vc], animated: true)
            return nvc
        }

        guard let _ = cityProvider?.currentCity.value else {
            let nvc = RootNavigationController.build(RootNavigationViewModel())
            nvc.navigationBar.hidden = true
            let vc = CitiesViewController.build(CitiesViewModel())
            nvc.setViewControllers([vc], animated: false)
            return nvc

        }

        return RootTabBarController.build(RootTabBarViewModel(setAsRoot: true))
    }
}

// MARK:- Notifications
extension App {
    /**
     Setup the app nottification settings
     
     - author: Nazih Shoura
     */
    func registerUserNotification() {
        let reminderNotificationAction = UIMutableUserNotificationAction()
        reminderNotificationAction.identifier = self.keys.ReminderNotificationActionIdentifier
        reminderNotificationAction.title = NSLocalizedString("Dismiss", comment: "")
        reminderNotificationAction.activationMode = .Background
        reminderNotificationAction.destructive = false
        reminderNotificationAction.authenticationRequired = false

        let reminderNotificationCategory = UIMutableUserNotificationCategory()
        reminderNotificationCategory.identifier = self.keys.ReminderNotificationIdentifier
        reminderNotificationCategory.setActions([reminderNotificationAction], forContext: .Default)
        let notificationCategories: Set<UIMutableUserNotificationCategory> = [reminderNotificationCategory]

        let notificationTypes: UIUserNotificationType = [.Alert, .Sound, .Badge]

        let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: notificationCategories)

        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }

    func registerRemoteNotification() {
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(pushNotificationSettings)

        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    func isRegisteredForRemoteNotifications() -> Bool {
        return UIApplication.sharedApplication().isRegisteredForRemoteNotifications()
    }

}

// MARK:- Cashe
extension App {
    static func clearCacheForMode() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                nil, forKey: "\(String(App)).mode")
    }

    static func cache(mode mode: Mode) {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(mode.rawValue, forKey: "\(String(App)).mode")
    }

    static func loadCacheForMode() -> Mode {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(String(App)).mode") as? Int else {
            App.clearCacheForMode()
            return Mode.Staging2
        }

        guard let mode = Mode(rawValue: data) else {
            App.clearCacheForMode()
            return Mode.Staging2
        }

        return mode
    }

    static func cache(isCompletedRequestEnableLocation isCompletedRequestEnableLocation: Bool) {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(isCompletedRequestEnableLocation, forKey: "\(String(App)).isCompletedRequestEnableLocation")
    }

    static func loadisCompletedRequestEnableLocation() -> Bool {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(String(App)).isCompletedRequestEnableLocation") as? Bool else {
            return false
        }

        return data
    }

    static func cache(isCompletedRequestEnableNotification isCompletedRequestEnableNotification: Bool) {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(isCompletedRequestEnableNotification, forKey: "\(String(App)).isCompletedRequestEnableNotification")
    }

    static func loadisCompletedRequestEnableNotification() -> Bool {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(String(App)).isCompletedRequestEnableNotification") as? Bool else {
            return false
        }

        return data
    }
}

enum Mode: Int, CaseCountable {
    case Release = 0
    case Staging
    case Staging2
    case Staging3
    case Staging4
    case Staging5
    case Whack
    case Echo

    var isDebug: Bool {
        switch self {
        case .Release: return false
        default: return true
        }
    }

    var isRelease: Bool {
        switch self {
        case .Release: return true
        default: return false
        }
    }

    var name: String {
        switch self {
        case Staging: return "Staging"
        case Staging2: return "Staging2"
        case Staging3: return "Staging3"
        case Staging4: return "Staging4"
        case Staging5: return "Staging5"
        case Release: return "Production"
        case Whack  : return "Whack"
        case Echo  : return "Echo"
        }
    }

    static var caseCount: Int = Mode.countCases()
}
