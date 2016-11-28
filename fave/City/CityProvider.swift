//
//  CityProvider.swift
//  FAVE
//
//  Created by Nazih Shoura on 02/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

protocol CityProvider: Refreshable, Cachable {
    var currentCity: Variable<City?> {get}

    var userSelectionDeducedCity: Variable<City?> {get}
    var sessionCity: Variable<City?> {get}
    var locationDeducedCity: Variable<City?> {get}

    func set(sessionCity city: City)
}

final class CityProviderDefault: Provider, CityProvider {

    // MARK:- Dependency
    let nearestCityAPI: NearestCityAPI
    let locationService: LocationService
    let wireframeService: WireframeService

    // Signals
    private let refreshSignal = PublishSubject<()>()

    // Provider variable
    var currentCity: Variable<City?>

    let userSelectionDeducedCity: Variable<City?>
    let sessionCity: Variable<City?>
    let locationDeducedCity: Variable<City?>

    init(
        nearestCityAPI: NearestCityAPI = NearestCityAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , wireframeService: WireframeService = wireframeServiceDefault
        ) {
        self.locationService = locationService
        self.nearestCityAPI = nearestCityAPI
        self.wireframeService = wireframeService

        let cashedLocationDeducedCity = CityProviderDefault.loadCasheForLocationDeducedCity()
        let cashedUserSelectionDeducedCity = CityProviderDefault.loadCasheForUserSelectionDeducedCity()

        self.locationDeducedCity = Variable(cashedLocationDeducedCity)
        self.userSelectionDeducedCity = Variable(cashedUserSelectionDeducedCity)
        self.sessionCity = Variable(nil)

        // currentCity will have the value of the cahed locationDeducedCity on launch, if it's nil, then the value of userSelectionDeducedCity
        self.currentCity = Variable(cashedUserSelectionDeducedCity)

        if let _ = cashedLocationDeducedCity {
            self.currentCity = Variable(cashedLocationDeducedCity)
        }

        super.init()

        // Assign any new value of locationDeducedCity to currentCity
        locationDeducedCity
            .asObservable()
            .skip(1) // The first value will be the cashed locationDeducedCity which was used to initiat currentCity
            .filter { (city) -> Bool in city != nil }
            .bindTo(currentCity)
            .addDisposableTo(disposeBag)

        // Assign any new value of userSelectionDeducedCity to currentCity
        userSelectionDeducedCity
            .asObservable()
            .skip(1) // The first value will be the cashed userSelectionDeducedCity which was used to initiat currentCity
            .filter { (city) -> Bool in city != nil }
            .bindTo(currentCity)
            .addDisposableTo(disposeBag)

        // Cache the locationDeducedCity city
        locationDeducedCity
            .asObservable()
            .filterNil()
            .subscribeNext { (city) in
                CityProviderDefault.cashe(locationDeducedCity: city)
            }.addDisposableTo(disposeBag)

        // Cache the userSelectionDeducedCity city
        userSelectionDeducedCity
            .asObservable()
            .filterNil()
            .subscribeNext { (city) in
                CityProviderDefault.cashe(userSelectionDeducedCity: city)
            }.addDisposableTo(disposeBag)

        // Request the nearest city once we receive a location
        locationService
            .userLocation
            .asObservable()
            .filterNil()
            .take(1)
            .subscribeNext { [weak self] (location) in
                self?.reqestNearestCity(location)
            }
            .addDisposableTo(disposeBag)

        // Whenever a refresh signal is received, take the last location and use it to request the nearest city
        refreshSignal
            .withLatestFrom(locationService.userLocation.asObservable().filterNil())
            .subscribeNext { [weak self] (location: CLLocation) in
                self?.reqestNearestCity(location)
            }
            .addDisposableTo(disposeBag)

        // Logout
        // Clear the cashe
        app
            .logoutSignal
            .subscribeNext { _ in
                CityProviderDefault.clearCasheForLocationDeducedCity()
                CityProviderDefault.clearCasheForUserSelectionDeducedCity()
            }.addDisposableTo(disposeBag)

        // Reset the cities
        app
            .logoutSignal
            .subscribeNext { [weak self] _ in
                self?.currentCity.value = nil
                self?.userSelectionDeducedCity.value = nil
                self?.locationDeducedCity.value = nil
                self?.sessionCity.value = nil
            }.addDisposableTo(disposeBag)

    }

    // If the user selects a city, currentCity will take the value of that selected city until the app relaunches
    func set(sessionCity city: City) {
        self.sessionCity.value = city
    }
}

extension CityProviderDefault {
    func refresh() {
        locationService.updateLocation()
        refreshSignal.onNext(())
    }
}

// MARK:- API
extension CityProviderDefault {
    func reqestNearestCity(location: CLLocation) {
        let nearestCityAPIRequestPayload = NearestCityAPIRequestPayload(
            latitude: location.coordinate.latitude
            , longitude: location.coordinate.longitude)

        _ = nearestCityAPI
            .nearestCity(withRequestPayload: nearestCityAPIRequestPayload)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(
                onNext: { [weak self] (nearestCityAPIResponsePayload: NearestCityAPIResponsePayload) in
                    self?.locationDeducedCity.value = nearestCityAPIResponsePayload.city
                }, onError: { [weak self] (error: ErrorType) in
                    self?.wireframeService.alertFor(error, actions: nil)
                }
            ).addDisposableTo(disposeBag)
    }

}

// MARK:- Cashe
extension CityProviderDefault {

    private final class func cashe(locationDeducedCity city: City) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(city)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.CityProviderDefault).locationDeducedCity")
    }

    private final class func loadCasheForLocationDeducedCity() -> City? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.CityProviderDefault).locationDeducedCity") as? NSData else {
            return nil
        }

        guard let city = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? City else {
            clearCasheForLocationDeducedCity() // Cought curropted data!
            return nil
        }

        return city
    }

    private final class func clearCasheForLocationDeducedCity() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                nil, forKey: "\(literal.CityProviderDefault).locationDeducedCity")
    }

    private final class func cashe(userSelectionDeducedCity city: City) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(city)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.CityProviderDefault).userSelectionDeducedCity")
    }

    private final class func loadCasheForUserSelectionDeducedCity() -> City? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.CityProviderDefault).userSelectionDeducedCity") as? NSData else {
            return nil
        }

        guard let city = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? City else {
            clearCasheForLocationDeducedCity() // Cought curropted data!
            return nil
        }

        return city
    }

    private final class func clearCasheForUserSelectionDeducedCity() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                nil, forKey: "\(literal.CityProviderDefault).userSelectionDeducedCity")
    }

}

enum CityProviderError: DescribableError {
    case CityCouldNotBeObtained

    var description: String {
        switch self {
        case .CityCouldNotBeObtained:
            return "City Could Not Be btained"
        }
    }

    var userVisibleDescription: String {
        switch self {
        case .CityCouldNotBeObtained:
            return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }

}
