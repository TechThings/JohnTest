//
//  AppDelegate.swift
//  FAVE
//
//  Created by Nazih Shoura on 02/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import Braintree
import ZendeskSDK
import SwiftLoader
import Fabric
import Crashlytics
import AppsFlyer
import MoEngage_iOS_SDK
import ZDCChat
import Branch
import GooglePlaces
import RxSwift
import RxCocoa
import Firebase
import SendBirdSDK
import Localytics
import MidtransKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let BRAINTREE_URL_SCHEME = appDefault.keys.BundleIDString + ".payments"

    func injectSingletonsDependancies() {
        appDefault.setLightHouseService()
        appDefault.setCityProvider()
        appDefault.setNetworkSevice()
        locationServiceDefault.setCityProvider()
    }

    func configureSwiftLoader() {
        var config: SwiftLoader.Config = SwiftLoader.Config()
        config.size = 100
        config.spinnerColor = .favePink()
        config.spinnerLineWidth = 3
        config.foregroundColor = .blackColor()
        config.foregroundAlpha = 0.2
        config.backgroundColor = UIColor(white: 1, alpha: 0.85)
        config.cornerRadius = 50
        SwiftLoader.setConfig(config)
    }

    func setupBranch(launchOptions: [NSObject: AnyObject]?) {

        let branch = Branch.getInstance()

        var finalLaunchOptions = launchOptions

        let launchOptionsBranch = modifiedLaunchOptionsWithBranchDeeplink(launchOptions)
        if launchOptionsBranch != nil {
            finalLaunchOptions = launchOptionsBranch
        }

        branch.initSessionWithLaunchOptions(finalLaunchOptions, andRegisterDeepLinkHandler: { optParams, error in
            if error == nil, let dict = optParams as? [String : AnyObject] {
                guard let linkModel = ParseDeeplink.parseFromDict(dict) else {return}
                self.handleDeepLink(linkModel)
            }
        })
    }

    func modifiedLaunchOptionsWithBranchDeeplink (launchOptions: [NSObject: AnyObject]?) -> [NSObject: AnyObject]? {
        var launchOptionsWithDeeplink = [NSObject: AnyObject]()

        // Copy all keys of launch options to new launch options
        guard let userInfoDict = launchOptions else {return nil}
        for value in userInfoDict.keys {
            launchOptionsWithDeeplink[value] = userInfoDict[value]
        }
        var finalDict = NSDictionary()

        // If remote notification exists, force unwrap as NSDictionary.
        guard let remotePayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] else {return nil}

        guard let newPayload = remotePayload as? NSDictionary else { return nil}

        // Create NSMutableDictionary to modify payload and add new branch key, if deeplink exists
        let payloadWithDeeplink = NSMutableDictionary(dictionary: newPayload)

        // Check if deeplink exists. If yes, assign to the mutable dict, which then goes as a NSDict into launchOptionsWithDeeplink
        if let extraPayload = payloadWithDeeplink["app_extra"] {
            if let moe_deeplink = extraPayload["moe_deeplink"] {

                payloadWithDeeplink["branch"] = moe_deeplink
                finalDict = NSDictionary(dictionary: payloadWithDeeplink)
                launchOptionsWithDeeplink[UIApplicationLaunchOptionsRemoteNotificationKey] = finalDict
            }
        }

        return launchOptionsWithDeeplink
    }

    func handleDeepLink(linkModel: LinkModel) {
        let deepLink = linkModel.deepLink
        let params = linkModel.params

        var vc: UIViewController? = nil

        switch linkModel.type {
        case .Home:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.home.rawValue
            return

        case .FAQ:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.more.rawValue
            guard let navController = UIViewController.currentViewController?.navigationController else {
                return
            }
            ZDKHelpCenter.setNavBarConversationsUIType(ZDKNavBarConversationsUIType.None)
            ZDKHelpCenter.pushHelpCenterWithNavigationController(navController)

        case .AccountSetting:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.more.rawValue
            vc = UserProfileViewController.build(deepLink, params: params)

        case .TalkToUs:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.more.rawValue
            let viewModel = SupportViewModel()
            ZDCChat.updateVisitor(viewModel.visitorInfo)
            ZDCChat.startChat(viewModel.chatConfig)

        case .Payment:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.more.rawValue
            vc = PaymentViewController.build(deepLink, params: params)

        case .Search:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.home.rawValue
            vc = OutletsSearchViewController.build(deepLink, params: params)

        case .Promo:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.more.rawValue
            vc = PromoViewController.build(deepLink, params: params)

        case .Favourites:
            UIView.animateWithDuration(0.0, animations: {
                RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.myFave.rawValue
            }) { (_) in
                if let myFaveNVC = RootTabBarController.shareInstance?.viewControllers?[RootTabBarControllerTab.myFave.rawValue] as? RootNavigationController {
                    if let myFaveVC = myFaveNVC.topViewController as? MyFaveViewController {
                        myFaveVC.setCurrentPage(MyFavePage.Favourite)
                    }
                }
            }

        case .Reservations:
            UIView.animateWithDuration(0.0, animations: {
                RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.myFave.rawValue
            }) { (_) in
                if let myFaveNVC = RootTabBarController.shareInstance?.viewControllers?[RootTabBarControllerTab.myFave.rawValue] as? RootNavigationController {
                    if let myFaveVC = myFaveNVC.topViewController as? MyFaveViewController {
                        myFaveVC.setCurrentPage(MyFavePage.Reservation)
                    }
                }
            }

        case .Collections:

            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.home.rawValue

            if let params = params, let _ = params["collection_id"] as? String {
                vc = ListingsCollectionViewController.build(deepLink, params: params)
            } else {
                vc = ListingsCollectionsViewController.build(deepLink, params: params)
            }

        case .Partner:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.home.rawValue
            vc = OutletViewController.build(deepLink, params: params)

        case .Offer:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.home.rawValue
            vc = ListingViewController.build(deepLink, params: params)

        case .Nearby:
            UIView.animateWithDuration(0.0, animations: {
                RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.nearby.rawValue
            }) { (_) in
                if let nearbyNVC = RootTabBarController.shareInstance?.viewControllers?[RootTabBarControllerTab.nearby.rawValue] as? RootNavigationController {
                    if let nearbyVC = nearbyNVC.topViewController as? NearbyViewController {
                        if let pageIndex = nearbyVC.viewModel.pageIndexFromDeepLink(linkModel.deepLink) {
                            nearbyVC.setCurrentPage(pageIndex)
                        }
                    }
                }
            }

        case .Chat:
            // CC: Move this somewhere else.
            // Need to support async construction of ViewModel
            let urlComponents = NSURLComponents(string: deepLink)
            let urlParams = urlComponents?.queryItems

            let channelUrl: String?

            if let channel_url = urlParams?.filter({$0.name == "channel_url"}).first?.value {
                channelUrl = channel_url
            } else {
                guard let params = params, let channel_url = params["channel_url"] as? String else { return }
                channelUrl = channel_url
            }

            if let channelUrl = channelUrl {
                channelProviderDefault.fetchChannel(channelUrl)
                    .map { (channelAPIResponsePayload: ChannelAPIResponsePayload) -> Channel in
                        return channelAPIResponsePayload.channel
                    }
                    .doOnError {
                        _ in
                    }
                    .subscribeNext {
                        (channel: Channel) in
                        guard let rootTabBar = RootTabBarController.shareInstance else {
                            print("RootTabBarController is null")
                            return
                        }

                        rootTabBar.selectedIndex = RootTabBarControllerTab.chat.rawValue
                        let chatVC = ChatContainerViewController.build(ChatContainerViewControllerViewModel(chatContainerViewControllerViewModelFunctionality: .InitiateIndependently(channel: Variable(channel))))
                        chatVC.hidesBottomBarWhenPushed = true
                        if let navController = rootTabBar.chatRootNavigationController {
                            if let previousVC = navController.viewControllers[safe: navController.viewControllers.count - 1],
                                let previousChatVC = previousVC as? ChatContainerViewController where
                                previousChatVC.viewModel.channel.value.url.absoluteString == channel.url.absoluteString {
                                // Do nothing. The active VC is the one we want to open
                                return
                            } else {
                                navController.popToRootViewControllerAnimated(true)
                            }

                            navController.pushViewController(chatVC, animated: true)
                        } else {
                            print("Chat NavContoller is null")
                        }
                    }.addDisposableTo(appDefault.disposeBag)
            }

        case .Credits:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.more.rawValue
            vc = CreditViewController.build(deepLink, params: params)

        case .Invite:
            RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.chat
            .rawValue
            if let navController = RootTabBarController.shareInstance?.chatRootNavigationController {
                let channelsViewController = ChannelsViewController.build(ChannelsViewControllerViewModel())
                navController.setViewControllers([channelsViewController], animated: false)
            }
        }

        if let vc = vc {
            UIViewController.currentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        injectSingletonsDependancies()
        configureSwiftLoader()
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = appDefault.appEntryViewController()

        // Initialize Third Party SDKs
        Fabric.with([Crashlytics.self])
        self.initializeAppsFlyer()
        self.initializeLocalytics(launchOptions)
        self.setupZendesk()
        self.initializeMoEngage(application, launchOptions: launchOptions)
        self.initializeFirebase()
        self.initializeSendBird()
        BTAppSwitch.setReturnURLScheme(BRAINTREE_URL_SCHEME)

        UITabBar.appearance().tintColor = UIColor.favePink()

        let descriptor = UIFontDescriptor(name: "CircularStd-Book", size: 16.0)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(descriptor: descriptor, size: 16.0)]

        self.setupBranch(launchOptions)
        GMSPlacesClient.provideAPIKey(appDefault.keys.GooglePlaceKey)

        // Refresh Push Token
        if (appDefault.isRegisteredForRemoteNotifications()) {
            application.registerForRemoteNotifications()
        }

        // Process Push Notification received when app is not open
        if let remoteNotif = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            self.handleCustomPushNotification(remoteNotif)
        }

        // veritrans 

        MidtransConfig.setClientKey(appDefault.keys.VERITRANS_MERCHANT_CLIENT_KEY, serverEnvironment: appDefault.keys.VT_SERVER_ENVIRONMENT, merchantURL: appDefault.keys.VERITRANS_MERCHANT_BASE_URL_String)

//        if let vtCardControllerConfig = VTCardControllerConfig.sharedInstance() as? VTCardControllerConfig {
//            vtCardControllerConfig.enable3DSecure = true
//        }

        return true
    }

    func initializeAppsFlyer() {
        AppsFlyerTracker.sharedTracker().appleAppID = appDefault.keys.AppleAppID
        AppsFlyerTracker.sharedTracker().appsFlyerDevKey = appDefault.keys.AppsFlyerDevKey
    }

    func initializeMoEngage(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        // Separate initialization methods for Dev and Prod initializations
        // openDeeplinkUrlAutomatically tells us whether you want the SDK to call handleOpenUrl for deeplinks specified while creating a campaign

        if(appDefault.mode.isDebug) {
            MoEngage.sharedInstance().initializeDevWithApiKey(appDefault.keys.MoEngageAppId, inApplication: application, withLaunchOptions: launchOptions, openDeeplinkUrlAutomatically:false)
        } else {
            MoEngage.sharedInstance().initializeProdWithApiKey(appDefault.keys.MoEngageAppId, inApplication: application, withLaunchOptions: launchOptions, openDeeplinkUrlAutomatically:false)
        }

        // FIXME: TODO
        // Differentiate between Install/Update
        //        MoEngage.sharedInstance().appStatus(INSTALL)
        //        MoEngage.sharedInstance().appStatus(UPDATE)
    }

    func initializeFirebase() {
        FIRApp.configureWithOptions(appDefault.keys.firebaseOptions)
        rxFirebaseMessengerDefault.connect()
    }

    func setupZendesk() {
        let identity = ZDKAnonymousIdentity()
        ZDKConfig.instance().userIdentity = identity

        let theme = ZDKTheme.baseTheme()
        theme.primaryBackgroundColor = UIColor(red: 241.0 / 255.0, green: 242.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
        theme.secondaryBackgroundColor = UIColor(red: 241.0 / 255.0, green: 242.0 / 255.0, blue: 243.0 / 255.0, alpha: 0.6)
        theme.apply()

        // Zopim
        ZDCVisitorChatCell.appearance().bubbleBorderColor = UIColor.faveBlue()
        ZDCVisitorChatCell.appearance().bubbleColor = UIColor.faveBlue()
        ZDCVisitorChatCell.appearance().bubbleCornerRadius = 3.0
        ZDCChat.initializeWithAccountKey(appDefault.keys.ZopimAccountKey)
    }

    func initializeSendBird() {
        rxSendBirdDefault.initAppId()
        rxSendBirdDefault.registerEventHandler()
        rxSendBirdDefault.login()
            .asDriver(onErrorJustReturn: SendBirdChannel())
            .driveNext {
                (channel: SendBirdChannel) in
                print("Connected to SendBird Channel")
            }.addDisposableTo(appDefault.disposeBag)
    }

    func initializeLocalytics(launchOptions: [NSObject: AnyObject]?) {
        if (appDefault.mode.isDebug) {
            Localytics.setLoggingEnabled(false)
        }

        Localytics.autoIntegrate(appDefault.keys.LocalyticsAppKey, launchOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        MoEngage.sharedInstance().stop(application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        MoEngage.sharedInstance().applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        // Track Installs, updates & sessions(app opens) (You must include this API to enable tracking)
        AppsFlyerTracker.sharedTracker().trackAppLaunch()
        MoEngage.sharedInstance().applicationBecameActiveinApplication(application)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        appDefault.lightHouseService?.appWillTerminate.onNext(())
        MoEngage.sharedInstance().applicationTerminated(application)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {

        if let string = url.absoluteString {
            if string.lowercaseString.hasPrefix("fave://") {
                if let linkModel = ParseDeeplink.parseDirectDeeplink(string) {
                    self.handleDeepLink(linkModel)
                }
            }
        }

        Branch.getInstance().handleDeepLink(url)

        if let urlScheme = url.scheme?.localizedCaseInsensitiveCompare(BRAINTREE_URL_SCHEME) {
            if urlScheme == .OrderedSame {
            return BTAppSwitch.handleOpenURL(url, sourceApplication:sourceApplication)
            }
        }

        // Reports app open from deeplink for iOS 8 or below
        AppsFlyerTracker.sharedTracker().handleOpenURL(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        return true
    }

    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity,
                     restorationHandler: ([AnyObject]?) -> Void) -> Bool {

        Branch.getInstance().continueUserActivity(userActivity)

        // Reports app open from a Universal Link for iOS 9
        AppsFlyerTracker.sharedTracker().continueUserActivity(userActivity, restorationHandler: restorationHandler)
        return true
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // Called when your app has received a remote notification.

        var userInfoWithDeeplink = userInfo
        if let extraPayload = userInfo["app_extra"] {
                if let moe_deeplink = extraPayload["moe_deeplink"] {
                    userInfoWithDeeplink["branch"] = moe_deeplink
                }
        }

        Branch.getInstance().handlePushNotification(userInfoWithDeeplink)

        MoEngage.sharedInstance().didReceieveNotificationinApplication(application, withInfo: userInfo, openDeeplinkUrlAutomatically:false)

        if (application.applicationState == .Background || application.applicationState == .Inactive) {
            self.handleCustomPushNotification(userInfo)
        } else {
            self.handleCustomPushNotificationForeground(userInfo)
        }
    }

    private func handleCustomPushNotification(userInfo: [NSObject : AnyObject]) {
        if let deeplink = rxSendBirdDefault.parsePushNotificationForDeepLink(userInfo) {
            self.handleDeepLink(deeplink)
        }
    }

    private func handleCustomPushNotificationForeground(userInfo: [NSObject : AnyObject]) {
        if let deeplink = rxSendBirdDefault.parsePushNotificationForDeepLink(userInfo) {
            if deeplink.type == .Invite {
                guard let title = deeplink.params?["title"] as? String else {
                    return
                }

                guard let message = deeplink.params?["message"] as? String else {
                    return
                }

                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
                let viewAction = UIAlertAction(title: NSLocalizedString("view", comment: ""), style: .Default, handler: {
                    _ in
                    RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.chat.rawValue
                    if let navController = RootTabBarController.shareInstance?.chatRootNavigationController {
                        let channelsViewController = ChannelsViewController.build(ChannelsViewControllerViewModel())
                        navController.setViewControllers([channelsViewController], animated: false)
                    }
                })
                let alertController = UIAlertController.alertController(forTitle: title, message: message, preferredStyle: UIAlertControllerStyle.Alert, actions: [cancelAction, viewAction])
                RootTabBarController.shareInstance?.chatRootNavigationController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // Sent to the delegate when Apple Push Notification service cannot successfully complete the registration process.

        MoEngage.sharedInstance().didFailToRegisterForPush()
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        // Called to tell the delegate the types of local and remote notifications that can be used to get the user’s attention.

        MoEngage.sharedInstance().didRegisterForUserNotificationSettings(notificationSettings)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).

        MoEngage.sharedInstance().registerForPush(deviceToken)
        rxSendBirdDefault.registerForRemoteNotifications(deviceToken)
        rxFirebaseMessengerDefault.registerForRemoteNotifications(deviceToken)
    }

}
