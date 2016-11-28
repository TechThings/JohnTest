//
//  RootTabBarViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

/**
 *  @author Nazih Shoura
 *
 *  RootTabBarViewModel
 */
final class RootTabBarViewModel: ViewModel {
    let setAsRoot: Bool

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let channelProvider: ChannelProvider
    let cityProvider: CityProvider

    // MARK- Output
    var tabBarViewControllers = Variable([UINavigationController]())
    init(
        setAsRoot: Bool
        , homeRootNavigationViewModel: RootNavigationViewModel = RootNavigationViewModel()
        , homeViewModel: HomeViewControllerViewModel = HomeViewControllerViewModel()
        , nearbyRootNavigationViewModel: RootNavigationViewModel = RootNavigationViewModel()
        , nearbyViewModel: NearbyViewModel = NearbyViewModel()
        , channelsViewControllerViewModel: ChannelsViewControllerViewModel = ChannelsViewControllerViewModel()
        , channelsRootNavigationControllerViewModel: RootNavigationViewModel = RootNavigationViewModel()
        , myFaveViewModel: MyFaveViewModel = MyFaveViewModel()
        , myFaveRootNavigationViewModel: RootNavigationViewModel = RootNavigationViewModel()
        , moreViewModel: MoreViewModel = MoreViewModel()
        , moreRootNavigationViewModel: RootNavigationViewModel = RootNavigationViewModel()
        , guestNavigationViewModel: RootNavigationViewModel = RootNavigationViewModel()
        , guestViewControllerViewModel: GuestViewControllerViewModel = GuestViewControllerViewModel()
        , cityProvider: CityProvider = cityProviderDefault
        , userProvider: UserProvider = userProviderDefault
        , channelProvider: ChannelProvider = channelProviderDefault
        ) {
        self.setAsRoot = setAsRoot
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.channelProvider = channelProvider

        let homeViewController = HomeViewController.build(homeViewModel)
        let homeRootNavigationController = RootNavigationController.build(homeRootNavigationViewModel)
        homeRootNavigationController.setViewControllers([homeViewController], animated: false)
        tabBarViewControllers.value.append(homeRootNavigationController)

        let nearbyViewController = NearbyViewController.build(nearbyViewModel)
        let nearbyRootNavigationController = RootNavigationController.build(nearbyRootNavigationViewModel)
        nearbyRootNavigationController.setViewControllers([nearbyViewController], animated: false)
        tabBarViewControllers.value.append(nearbyRootNavigationController)

        let channelsViewController = ChannelsViewController.build(channelsViewControllerViewModel)
        let channelsRootNavigationController = RootNavigationController.build(channelsRootNavigationControllerViewModel)
        channelsRootNavigationController.setViewControllers([channelsViewController], animated: false)
        tabBarViewControllers.value.append(channelsRootNavigationController)

        let myFaveViewController = MyFaveViewController.build(myFaveViewModel)
        let myFaveRootNavigationController = RootNavigationController.build(myFaveRootNavigationViewModel)
        myFaveRootNavigationController.setViewControllers([myFaveViewController], animated: false)
        tabBarViewControllers.value.append(myFaveRootNavigationController)

        if userProvider.currentUser.value.isGuest {
            let guestViewController = GuestViewController.build(guestViewControllerViewModel)
            let guestRootNavigationController = RootNavigationController.build(moreRootNavigationViewModel)
            guestRootNavigationController.setViewControllers([guestViewController], animated: false)
            tabBarViewControllers.value.append(guestRootNavigationController)
        } else {
            let moreViewController = MoreViewController.build(moreViewModel)
            let moreRootNavigationController = RootNavigationController.build(moreRootNavigationViewModel)
            // CC: Hack for the help view controller, find a way to change it's view background color to "F1F2F3"
            moreRootNavigationController.view.backgroundColor = UIColor(hexStringFast: "F1F2F3")
            moreRootNavigationController.setViewControllers([moreViewController], animated: false)
            tabBarViewControllers.value.append(moreRootNavigationController)
        }
    }
}
