//
//  LightHouseService.swift
//  FAVE
//
//  Created by Nazih Shoura on 25/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AppEvent {
    case listingPurchased(listing: ListingType)
    case reservationCanceled(reservation: Reservation)
    case channelCreated(channel: Channel)
}

typealias SetViewControllerClosure = ((viewController: UIViewController) -> ())

/// A clouser that takes a UIViewController and uses it to navigate to another UIVIewController
typealias NavigationClosure = ((viewController: UIViewController) -> ())

protocol LightHouseService {
    var navigate: PublishSubject<NavigationClosure> {get}
    var appEvent: PublishSubject<AppEvent> {get}
    var appWillTerminate: PublishSubject<()> {get}
    var setViewControllerClosure: PublishSubject<SetViewControllerClosure> {get}
}

final class LightHouseServiceDefault: LightHouseService {
    let navigate = PublishSubject<NavigationClosure>()
    let appEvent = PublishSubject<AppEvent>()
    let appWillTerminate = PublishSubject<()>()
    let setViewControllerClosure = PublishSubject<SetViewControllerClosure>()
}

// MARK:- FAVE Specific
extension LightHouseServiceDefault {}
