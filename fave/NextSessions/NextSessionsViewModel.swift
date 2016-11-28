//
//  NextSessionsViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/29/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SessionsItem {
    let date: NSDate
    let items: [ClassSession]

    init(date: NSDate, items: [ClassSession]) {
        self.date = date
        self.items = items
    }
}

/**
 *  @author Thanh KFit
 *
 *  NextSessionsViewModel
 */
final class NextSessionsViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    private let nextSessionsAPI: NextSessionsAPI

    // MARK:- Input
    let listingTimeSlotDetails: ListingTimeSlotDetailsType

    // MARK:- Intermediate

    // MARK- Output
    let nextSessions = Variable([SessionsItem]())

    init(
        nextSessionsAPI: NextSessionsAPI = NextSessionsAPIDefault()
        , listingTimeSlotDetails: ListingTimeSlotDetailsType
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.nextSessionsAPI = nextSessionsAPI
        self.listingTimeSlotDetails = listingTimeSlotDetails
    }
}

// MARK:- Refreshable
extension NextSessionsViewModel: Refreshable {
    func refresh() {
        let requestPayload = NextSessionsAPIRequestPayload(listingId: listingTimeSlotDetails.id)
        _ = nextSessionsAPI.getNextSessions(withRequestPayload: requestPayload)
            .trackActivity(app.activityIndicator)
            .subscribe(
                onNext: { [weak self] in
                    let group = $0.classSessions.categorise {$0.startDateTime.startOfDay()}.sort {$0.0.0 < $0.1.0}
                    let result = group.map {return SessionsItem(date: $0.0, items: $0.1)}
                    self?.nextSessions.value = result
                }, onError: { [weak self] (error: ErrorType) in
                    self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                        viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                    }
                }).addDisposableTo(disposeBag)

    }
}
