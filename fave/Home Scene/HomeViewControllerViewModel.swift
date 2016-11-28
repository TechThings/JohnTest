//
//  HomeViewControllerViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum HomeItemKind {
    case Search
    case Filter
    case Listings
    case Outlets
    case ListingsCollections

    var cellHeight: CGFloat {
        switch self {
        case .Search:
            let deviceHeight =  UIScreen.mainHeight
            return (0.4 * deviceHeight)

        case .Filter: return 90
        case .Listings: return 280
        case .Outlets: return 325
        case .ListingsCollections: return 330

        }
    }
}

/**
 *  @author Thanh KFit
 *
 *  HomeViewControllerViewModel
 */
final class HomeViewControllerViewModel: ViewModel {

    // Dependencies

    // Screen Tracking
    let trackingScreen: TrackingScreen
    let userProvider: UserProvider

    private let unReviewsAPI: UnReviewsAPI
    var unReviews: [Reservation] = [Reservation]()
    let writeReviewVC = Variable<WriteReviewViewController?>(nil)

    init(
        unReviewsAPI: UnReviewsAPI = UnReviewsAPIDefault()
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , userProvider: UserProvider = userProviderDefault
        ) {
        self.trackingScreen = trackingScreen
        self.unReviewsAPI = unReviewsAPI
        self.userProvider = userProvider
        super.init()
        requestUnReviews()
        trackCity()
    }

    func requestUnReviews() {
        let response = unReviewsAPI
            .unReview(withRequestPayload: UnReviewsAPIRequestPayload())

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError({ [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                })
                })
            .map({ (unReviewsAPIResponsePayload: UnReviewsAPIResponsePayload) -> [Reservation] in
                return unReviewsAPIResponsePayload.unReviews
            })
            .subscribeNext { [weak self] (unReviews: [Reservation]) in
                self?.unReviews = unReviews
                self?.popWriteReviewVC()
            }
            .addDisposableTo(disposeBag)
    }

    func popWriteReviewVC() {
        if unReviews.count > 0 {
            let reservation = unReviews.removeFirst()
            let vm = WriteReviewViewControllerViewModel(reservation: reservation)
            let vc = WriteReviewViewController.build(vm)
            writeReviewVC.value = vc
        }
    }

    func trackCity() {
        let analyticsModel = UserAnalyticsModel(user: self.userProvider.currentUser.value)
        analyticsModel.identifyUserWithCity()
    }
}
