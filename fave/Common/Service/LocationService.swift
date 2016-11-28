//
//  LocationService.swift
//  KFIT
//
//  Created by Nazih Shoura on 13/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

enum LocationAuthorizationType {
    case AlwaysOn
    case WhenInUse
}

protocol LocationService: Cachable {

    /**
     The location of the user. The value will be nil until the user location is obtained
     
     - author: Nazih Shoura
     */
    var userLocation: Variable<CLLocation?> {get}

    /**
     The location of the city center. The value will be nil  until the city is obtained
     
     - author: Nazih Shoura
     */
    var currentCityCenter: Variable<CLLocation?> {get}

    /**
     The current location used in the API calls. The value will be nil  until the location of the user is obtained or city is obtained
     
     - author: Nazih Shoura
     */
    var currentLocation: Variable<CLLocation?> {get}

    /**
     The current location permission. The location will start updating automatically once the value changes to anything that permits obtaining the location.
     
     - author: Nazih Shoura
     */
    var locationPermission: Variable<CLAuthorizationStatus> {get}

    /**
     Update base on currentLocation.
     */

    var isAllowedLocationPermission: Variable<Bool> {get}

    /**
     The interval for which the location service will keep updating the user location for after asking for it using 'updateLocation'
     
     - author: Nazih Shoura
     
     - seealso updateLocation
     */

    var updatingLocationTimeIntervaldefault: NSTimeInterval {get}

    /**
     Update the location and stop updating after a the location service's default location updating time interval
     
     - author: Nazih Shoura
     
     - seealso updatingLocationTimeIntervaldefault
     
     - parameter timeInterval: The period after which updating the location will stop, pass nil to use the default time interval
     */
    func updateLocation()

    /**
     Request the location autherization
     
     - author: Nazih Shoura
     
     - parameter locationAuthorizationType: The type of the authorization to be requested
     */
    func requestLocationPermission(locationAuthorizationType: LocationAuthorizationType)

    func setCityProvider(cityProvider: CityProvider)

}

final class LocationServiceDefault: Service, LocationService {
    private var cityProvider: CityProvider? = nil
    private let locationManager = CLLocationManager()
    private var locationUpdateTimer: NSTimer!

    let userLocation: Variable<CLLocation?>
    let currentCityCenter: Variable<CLLocation?>
    let sessionCityCenter: Variable<CLLocation?>

    /// The current location, it will have the value of the cahed userLocation on launch, if it's nil, then the value of currentCityCenter
    var currentLocation: Variable<CLLocation?>

    let locationPermission: Variable<CLAuthorizationStatus> = Variable(CLLocationManager.authorizationStatus())

    let isAllowedLocationPermission: Variable<Bool>
        = Variable(CLLocationManager.authorizationStatus() == .AuthorizedAlways
                    || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse)

    let updatingLocationTimeIntervaldefault: NSTimeInterval = 20 // Keep updating for 20 seconds

    init(
        ) {

        let cachedUserLocation = LocationServiceDefault.loadCacheForUserLocation()
        let cachedCurrentCityCenter = LocationServiceDefault.loadCurrentCityCenter()

        self.userLocation = Variable(cachedUserLocation)
        self.currentCityCenter = Variable(cachedCurrentCityCenter)
        self.sessionCityCenter = Variable(nil)

        // currentLocation will have the value of the cahed userLocation on launch, if it's nil, then the value of currentCityCenter

        self.currentLocation = Variable(cachedCurrentCityCenter)
        if let cachedLocation =  cachedUserLocation {
            self.currentLocation = Variable(cachedLocation)
        }

        super.init()

        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        // Assign any new location to userLocation
        locationManager
            .rx_didUpdateLocations
            .flatMap({ (locations: [CLLocation]) -> Observable<CLLocation?> in
                return Observable.of(locations.last)
            })
            .bindTo(userLocation)
            .addDisposableTo(disposeBag)

        // Cache the userLocation city
        userLocation
            .asObservable()
            .filterNil()
            .subscribeNext({ (location: CLLocation) in
                LocationServiceDefault.cache(userLocation: location)
            })
            .addDisposableTo(disposeBag)

        locationManager
            .rx_didChangeAuthorizationStatus
            .bindTo(locationPermission)
            .addDisposableTo(disposeBag)

        // Assign any new value of userLocation to currentLocation
        userLocation
            .asObservable()
            .skip(1) // The first value will be the cashed userLocation which was used to initiat currentLocation
            .filter({ (location: CLLocation?) -> Bool in
                location != nil
            })
            .bindTo(currentLocation)
            .addDisposableTo(disposeBag)

        // Assign any new value of currentCityCenter to currentLocation
        currentCityCenter
            .asObservable()
            .skip(1) // The first value will be the cashed currentCityCenter which was used to initiat currentLocation
            .filter({ (location: CLLocation?) -> Bool in
                return location != nil
            })
            .bindTo(currentLocation)
            .addDisposableTo(disposeBag)

        // Update the user location whenever you get a permission
        locationPermission
            .asObservable()
            .filter({ (authorizationStatus: CLAuthorizationStatus) -> Bool in
                authorizationStatus == .AuthorizedAlways || authorizationStatus == .AuthorizedWhenInUse
            })
            .subscribeNext { [weak self] _ in self?.updateLocation()
        }.addDisposableTo(disposeBag)

        // Update userLocationPermission whenever you get a new permission
        locationPermission
            .asObservable()
            .map({ (authorizationStatus: CLAuthorizationStatus) -> Bool in
                authorizationStatus == .AuthorizedAlways || authorizationStatus == .AuthorizedWhenInUse
            }).bindTo(isAllowedLocationPermission)
            .addDisposableTo(disposeBag)

        // Update the user location on initiation
        updateLocation()
    }

    @objc
    func updateLocation() {
        if isAllowedLocationPermission.value == true {
            locationManager.startUpdatingLocation()
            locationManager.performSelector(#selector(CLLocationManager.stopUpdatingLocation), withObject: nil, afterDelay:updatingLocationTimeIntervaldefault)
        }
    }

    func requestLocationPermission(locationAuthorizationType: LocationAuthorizationType) {
        switch locationAuthorizationType {
        case .AlwaysOn:
            locationManager.requestAlwaysAuthorization()
        case .WhenInUse:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func setCityProvider(cityProvider: CityProvider = cityProviderDefault) {
        self.cityProvider = cityProvider

        // Assign any new center of currentCity to currentCityCenter
        self.cityProvider!
            .currentCity
            .asObservable()
            .filterNil()
            .map { (city) in city.coordinates}
            .bindTo(currentCityCenter)
            .addDisposableTo(disposeBag)

        // Cache the currentCityCenter city
        currentCityCenter
            .asObservable()
            .filterNil()
            .subscribeNext { (city) in LocationServiceDefault.cache(currentCityCenter: city)
            }.addDisposableTo(disposeBag)
    }
}

extension LocationServiceDefault {
    private static func clearCacheForUserLocation() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(nil
                , forKey: "\(literal.LocationServiceDefault).userLocation")
    }

    private static func cache(userLocation location: CLLocation) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(location)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.LocationServiceDefault).userLocation")
    }

    private static func loadCacheForUserLocation() -> CLLocation? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.LocationServiceDefault).userLocation") as? NSData else {
            return nil
        }

        guard let location = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CLLocation else {
            clearCacheForUserLocation()
            return nil
        }

        return location
    }

    private static func clearCacheForCurrentCityCenter() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(nil
                , forKey: "\(literal.LocationServiceDefault).currentCityCenter")
    }

    private static func cache(currentCityCenter location: CLLocation) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(location)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.LocationServiceDefault).currentCityCenter")
    }

    private static func loadCurrentCityCenter() -> CLLocation? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.LocationServiceDefault).currentCityCenter") as? NSData else {
            return nil
        }

        guard let location = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CLLocation else {
            clearCacheForUserLocation()
            return nil
        }

        return location
    }

}
