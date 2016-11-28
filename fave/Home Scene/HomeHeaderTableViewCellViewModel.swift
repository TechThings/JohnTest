//
//  HomeHeaderTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeHeaderTableViewCellViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let pendingNotificationsAPI: PendingNotificationsAPI
    private let assetProvider: AssetProvider

    let name: Driver<String>
    let appImage: Driver <UIImage?>

    let pendingNotifications = Variable([PendingNotification]())
    let openNotificationDidTap = PublishSubject<()>()

    // MARK:- Signl
    let didTapSearchButton = PublishSubject<()>()

    init(
        userProvider: UserProvider = userProviderDefault
        , pendingNotificationsAPI: PendingNotificationsAPI = PendingNotificationsAPIDefault()
        , assetProvider: AssetProvider = assetProviderDefault
        ) {

        self.userProvider = userProvider
        self.pendingNotificationsAPI = pendingNotificationsAPI
        self.assetProvider = assetProvider

        appImage = assetProvider.imageAssest.asDriver().map({ (imgAsset: ImageAssest) -> UIImage? in
            imgAsset.welcomeImage
        })

        name = userProvider
            .currentUser
            .asDriver()
            .map {
                (user: User) -> String in
                if user.isGuest { return assetProvider.textAssest.value.welcomeText} else {
                    var name = NSLocalizedString("there", comment: "")
                    if user.name != nil { name = user.name! }
                    return "\(NSLocalizedString("hi", comment: "")) ".stringByAppendingString(name)
                }
        }

        super.init()

        openNotificationDidTap
            .subscribeNext { [weak self] _ in
                guard let pendingNotification = self?.pendingNotifications.value.first else { return }

                switch pendingNotification.type {
                case .Purchase:

                    UIView.animateWithDuration(0.0, animations: {
                        RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.myFave.rawValue
                    }) { (_) in
                        if let myFaveNVC = RootTabBarController.shareInstance?.viewControllers![RootTabBarControllerTab.myFave.rawValue] as? RootNavigationController {
                            if let myFaveVC = myFaveNVC.topViewController as? MyFaveViewController {
                                myFaveVC.setCurrentPage(MyFavePage.Reservation)
                                if let reservationId = pendingNotification.reservationId {
                                    let vm = RedemptionViewModel(reservationId: reservationId)
                                    let vc = RedemptionViewController.build(vm)
                                    myFaveVC.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }

                    }

                case .Invite:
                    RootTabBarController.shareInstance?.selectedIndex = RootTabBarControllerTab.chat.rawValue
                }
            }
            .addDisposableTo(disposeBag)

        didTapSearchButton
            .subscribeNext { [weak self] _ in
                guard let strongSelf = self else { return }
                let vm = OutletsSearchViewModel()
                let vc = OutletsSearchViewController.build(vm)
                strongSelf
                    .lightHouseService.navigate.onNext { (viewController: UIViewController) in
                        viewController.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .addDisposableTo(disposeBag)
    }

    func requestPendingNotifications() {
        let request = pendingNotificationsAPI.pendingNotifications(withRequestPayload: PendingNotificationsAPIRequestPayload())

        request
            .trackActivity(app.activityIndicator)
            .trackActivity(activityIndicator)
            .map { (pendingNotificationsAPIResponsePayload: PendingNotificationsAPIResponsePayload) -> [PendingNotification] in
                return pendingNotificationsAPIResponsePayload.pendingNotifications
            }
            .bindTo(pendingNotifications)
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension HomeHeaderTableViewCellViewModel: Refreshable {
    func refresh() {
        requestPendingNotifications()
    }
}
