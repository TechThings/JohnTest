//
//  SharedInstances.swift
//  FAVE
//
//  Created by Nazih Shoura on 02/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

let loggerDefault = Logger()

let paymentServiceDefault = PaymentServiceDefault()

let assetProviderDefault = AssetProviderDefault()

let networkServiceDefault = NetworkServiceDefault()

let apiServiceDefault = APIServiceDefault()

let wireframeServiceDefault = WireframeServiceDefault()

let userProviderDefault = UserProviderDefault()

let locationServiceDefault = LocationServiceDefault()

let cityProviderDefault = CityProviderDefault()

let filterProviderDefault = FilterProviderDefault()

let lightHouseServiceDefault = LightHouseServiceDefault()

let appDefault = App()

let reservationMade = PublishSubject<Reservation>()

let favoriteOutletModelDefault = FavoriteOutletModel()

let rxAnalyticsDefault = RxAnalyticsDefault(analyticTrackers: AppsFlyerAnalyticTracker(), MoEngageAnalyticTracker(), LocalyticsAnalyticTracker())

let rxSendBirdDefault = RxSendBirdDefault()

let rxFirebaseMessengerDefault = RxFirebaseMessengerDefault()

let channelProviderDefault = ChannelProviderDefault()

let trackingScreenDefault = TrackingScreenDefault()

let settingsProviderDefault = SettingsProviderDefault()
