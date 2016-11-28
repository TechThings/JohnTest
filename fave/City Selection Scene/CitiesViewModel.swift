//
//  CitiesViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 07/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  CitySelectionViewModel
 */
final class CitiesViewModel: ViewModel {

    // MARK:- Dependency
    private let citiesAPI: CitiesAPI
    private let wireframeService: WireframeService
    let locationService: LocationService
    let cityProvider: CityProvider
    let userProvider: UserProvider

    // MARK:- Intermidiate
    let citiesAPIObserver: Observable<CitiesAPIResponsePayload>!

    // MARK- Output
    let cities: Driver<[City]>

    init(
        citiesAPI: CitiesAPI = CitiesAPIDefault()
        , cityProvider: CityProvider = cityProviderDefault
        , userProvider: UserProvider = userProviderDefault
        , wireframeService: WireframeService = wireframeServiceDefault
        , locationService: LocationService = locationServiceDefault
        ) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.citiesAPI = citiesAPI
        self.wireframeService = wireframeService
        self.locationService = locationService
        self.citiesAPIObserver = citiesAPI.cities(withRequestPayload: CitiesAPIRequestPayload())
        self.cities = citiesAPIObserver
            .map { (citiesAPIResponsePayload: CitiesAPIResponsePayload) -> [City] in
                return citiesAPIResponsePayload.cities }
            .asDriver(onErrorJustReturn: [City]())
        super.init()
        refresh()
    }
}

// MARK:- Refreshable
extension CitiesViewModel: Refreshable {
    func refresh() {
        _ = citiesAPIObserver.trackActivity(app.activityIndicator).subscribeError { [weak self] (error) in
            self?.wireframeService.alertFor(error, actions: nil)
        }.addDisposableTo(disposeBag)
    }
}
