//
//  RootTabBarController.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift

enum RootTabBarControllerTab: Int {
    case home = 0
    case nearby
    case chat
    case myFave
    case more

    var rootNavigationController: UINavigationController? {
        switch self {
        case .home: return RootTabBarController.shareInstance?.homeRootNavigationController
        case .nearby: return RootTabBarController.shareInstance?.nearbyRootNavigationController
        case .chat: return RootTabBarController.shareInstance?.chatRootNavigationController
        case .myFave: return RootTabBarController.shareInstance?.myFaveRootNavigationController
        case .more: return RootTabBarController.shareInstance?.moreRootNavigationController
        }
    }

    static var selectedRootTabBarControllerTab: RootTabBarControllerTab? = {
        guard let selectedIndex = RootTabBarController.shareInstance?.selectedIndex else { return nil }
        let result = RootTabBarControllerTab(rawValue: selectedIndex)
        return result
    }()

    func setAsSelected() {
        RootTabBarController.shareInstance?.selectedViewController = self.rootNavigationController
    }
}

final class RootTabBarController: TabBarController {

    var viewModel: RootTabBarViewModel!
    var compositeDisposeBag: CompositeDisposable!
    static var shareInstance: RootTabBarController? = nil

    weak var homeRootNavigationController: UINavigationController?
    weak var nearbyRootNavigationController: UINavigationController?
    weak var chatRootNavigationController: UINavigationController?
    weak var myFaveRootNavigationController: UINavigationController?
    weak var moreRootNavigationController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.logger.log("\(self.subjectLabel) did load", loggingMode: .info, logingTags: [.memoryLeaks, .ui], shouldShowCodeLocation: false)

        delegate = self

        // CC
        // Update User's Identifier
        // This has the side effect of UPDATING the local user cache as well (if network call is successful)
        userProviderDefault
            .currentUser
            .asObservable()
            .filter { (currentUser: User) -> Bool in !currentUser.isGuest}
            .take(1) // Prevent infinite loop :(
            .subscribeNext {
                _ -> () in
                userProviderDefault.updateProfileRequest(true,
                    dateOfBirth: nil,
                    gender: nil,
                    purchaseNotification: nil,
                    marketingNotification: nil,
                    advertisingId: appDefault.advertisingId,
                    profileImage: nil
                )
            }
            .addDisposableTo(disposeBag)

        // Update the unread count in tab bar
        channelProviderDefault
            .channels
            .asObservable()
            .map { (channels: [Channel]) -> [Int] in
                return channels.map({ (channel: Channel) -> Int in
                    guard let sendBirdChannel = channel.messagingServiceChannel.value else {
                        return 0
                    }

                    return Int(sendBirdChannel.unreadMessageCount)
                })
            }
            .map {
                (unreads: [Int]) -> Int in
                return unreads.reduce(0, combine: +)
            }
            .subscribeNext { [weak self] (unreadCount: Int) in
                self?.chatRootNavigationController?.tabBarItem.badgeValue = unreadCount > 0 ? "\(unreadCount)" : nil
            }
            .addDisposableTo(disposeBag)

        bind()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if viewModel.setAsRoot { self.view.window?.rootViewController = self}

        // Present the city selection to obtain it
        if viewModel.cityProvider.currentCity.value == nil {
            let citiesNavigationViewController = RootNavigationController.build(RootNavigationViewModel())
            citiesNavigationViewController.navigationBar.hidden = true
            let citiesViewController = CitiesViewController.build(CitiesViewModel())
            citiesNavigationViewController.setViewControllers([citiesViewController], animated: false)
            presentViewController(citiesNavigationViewController, animated: true, completion: nil)
        }
    }

    var onScreenController: UIViewController?

    deinit {
        viewModel.logger.log("\(self.subjectLabel) will deinit", loggingMode: .info, logingTags: [.memoryLeaks, .ui], shouldShowCodeLocation: false)
    }
}

extension RootTabBarController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if onScreenController == viewController {
            if let navVC = viewController as? UINavigationController, let vc = navVC.viewControllers.first as? Scrollable {
                vc.scrollToTop()
            }
        }
        onScreenController = viewController
    }
}

extension RootTabBarController: ViewModelBindable {
    func bind() {

        viewModel
            .tabBarViewControllers
            .asObservable()
            .subscribeNext { [weak self] tabBarViewControllers in
            self?.setViewControllers(tabBarViewControllers, animated: false)

            self?.viewControllers![RootTabBarControllerTab.home.rawValue].tabBarItem = UITabBarItem(title: NSLocalizedString("main_tab_home_text", comment: "").capitalizedString, image: UIImage(named:"ic_tab_home")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage:  UIImage(named:"ic_tab_home"))
            self?.viewControllers![RootTabBarControllerTab.nearby.rawValue].tabBarItem = UITabBarItem(title: NSLocalizedString("main_tab_nearby_text", comment: "").capitalizedString, image: UIImage(named:"ic_tab_nearby")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named:"ic_tab_nearby"))
            self?.viewControllers![RootTabBarControllerTab.chat.rawValue].tabBarItem = UITabBarItem(title: NSLocalizedString("main_tab_chat_text", comment: "").capitalizedString, image: UIImage(named:"ic_tab_chat")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named:"ic_tab_chat"))
            self?.viewControllers![RootTabBarControllerTab.myFave.rawValue].tabBarItem = UITabBarItem(title: NSLocalizedString("main_tab_my_fave_text", comment: "").capitalizedString, image: UIImage(named:"ic_tab_myfave")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named:"ic_tab_myfave"))
            self?.viewControllers![RootTabBarControllerTab.more.rawValue].tabBarItem = UITabBarItem(title: NSLocalizedString("main_tab_more_text", comment: "").capitalizedString, image: UIImage(named:"ic_tab_more")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named:"ic_tab_more"))

            self?.homeRootNavigationController = self?.viewControllers![RootTabBarControllerTab.home.rawValue] as? UINavigationController
            self?.nearbyRootNavigationController = self?.viewControllers![RootTabBarControllerTab.nearby.rawValue] as? UINavigationController
            self?.chatRootNavigationController = self?.viewControllers![RootTabBarControllerTab.chat.rawValue] as? UINavigationController
            self?.myFaveRootNavigationController = self?.viewControllers![RootTabBarControllerTab.myFave.rawValue] as? UINavigationController
            self?.moreRootNavigationController = self?.viewControllers![RootTabBarControllerTab.more.rawValue] as? UINavigationController
        }
        .addDisposableTo(disposeBag)

    }
}

extension RootTabBarController: Buildable {
    final class func build(builder: RootTabBarViewModel) -> RootTabBarController {
        let storyboard = UIStoryboard(name: "RootTabController", bundle: nil)
        let rootTabBarController = storyboard.instantiateViewControllerWithIdentifier(String(RootTabBarController)) as! RootTabBarController
        rootTabBarController.viewModel = builder
        shareInstance = rootTabBarController
        return rootTabBarController
    }
}
