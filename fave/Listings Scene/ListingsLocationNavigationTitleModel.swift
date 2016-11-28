//
//  ListingsLocationNavigationTitleModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import GooglePlaces

/**
 *  @author Thanh KFit
 *
 *  ListingsLocationNavigationTitleViewModel
 */
final class ListingsLocationNavigationTitleModel: ViewModel, Cachable {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    private let locationService: LocationService

    // MARK:- Variable

    //MARK:- Input
    let titleOverlayButtonDidTap = PublishSubject<Void>()

    // MARK:- Intermediate

    // MARK- Output
    let locationName: Variable<String>
    let location: Variable<CLLocation?>

    init(
        locationService: LocationService = locationServiceDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.locationService = locationService

        let cachedLocation = ListingsLocationNavigationTitleModel.loadCacheForLocation()
        location = Variable(cachedLocation)

        let cachedLocationName = ListingsLocationNavigationTitleModel.loadCacheForLocationName()
        locationName = Variable(cachedLocationName)

        super.init()

        if location.value == nil {
            resetLocation()
        }

        location
            .asObservable()
            .filterNil()
            .subscribeNext({ (location: CLLocation) in
                ListingsLocationNavigationTitleModel.cache(location: location)
            })
            .addDisposableTo(disposeBag)

        locationName
            .asObservable()
            .subscribeNext({ (locationName: String) in
                ListingsLocationNavigationTitleModel.cache(locationName: locationName)
            })
            .addDisposableTo(disposeBag)

        lightHouseService
            .appWillTerminate
            .subscribeNext { _ in
                ListingsLocationNavigationTitleModel.clearCacheForLocation()
                ListingsLocationNavigationTitleModel.clearCacheForLocationName()
            }.addDisposableTo(disposeBag)

        titleOverlayButtonDidTap.subscribeNext { [weak self] () in
            guard let strongSelf = self else { return }
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            strongSelf.trackingScreen.trackingScreen(screenName.SCREEN_CHANGE_LOCATION)

            self?.lightHouseService.navigate.onNext { viewController in
                viewController.presentViewController(autocompleteController, animated: true, completion: nil)
            }}.addDisposableTo(disposeBag)
    }

    func resetLocation() {
        if let coordinate = locationService.currentLocation.value {
            location.value = coordinate
            CLGeocoder().reverseGeocodeLocation(coordinate) {(placeMarks, error) in
                if let error = error {
                    self.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                        let alertController = UIAlertController.alertController(forError: error, actions: nil)
                        viewController.presentViewController(alertController, animated: true, completion: nil)
                    }
                }

                if let placeMarks = placeMarks, let pm = placeMarks[safe: 0], let name = pm.name {
                    self.locationName.value = name
                }
            }
        }
    }

}

extension ListingsLocationNavigationTitleModel: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        location.value = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        locationName.value = place.name

        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
    }

    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

}

extension ListingsLocationNavigationTitleModel {
    private static func clearCacheForLocation() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(nil
                , forKey: "\(literal.ListingsLocationNavigationTitleModel).location")
    }

    private static func cache(location location: CLLocation) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(location)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.ListingsLocationNavigationTitleModel).location")
    }

    private static func loadCacheForLocation() -> CLLocation? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.ListingsLocationNavigationTitleModel).location") as? NSData else {
            return nil
        }

        guard let location = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CLLocation else {
            clearCacheForLocation()
            return nil
        }

        return location
    }

    private static func clearCacheForLocationName() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(nil
                , forKey: "\(literal.ListingsLocationNavigationTitleModel).locationName")
    }

    private static func cache(locationName locationName: String) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(locationName)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.ListingsLocationNavigationTitleModel).locationName")
    }

    private static func loadCacheForLocationName() -> String {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.ListingsLocationNavigationTitleModel).locationName") as? NSData else {
            return ""
        }

        guard let locationName = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? String else {
            clearCacheForLocation()
            return ""
        }

        return locationName
    }
}
