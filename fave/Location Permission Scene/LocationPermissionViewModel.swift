//
//  LocationPermissionViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 06/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  LocationPermissionViewModel
 */
final class LocationPermissionViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    let locationService: LocationService
    let cityProvider: CityProvider
    let userProvider: UserProvider

    init (
        locationService: LocationService = locationServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        , userProvider: UserProvider = userProviderDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.locationService = locationService
        self.cityProvider = cityProvider
        self.userProvider = userProvider
    }
}
