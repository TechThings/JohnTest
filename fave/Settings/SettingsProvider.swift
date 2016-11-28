//
//  SettingsProvider.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/9/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

protocol SettingsProvider: Cachable {
    var settings: Variable<Settings> {get}
    func updateSettings()
}

final class SettingsProviderDefault: Provider, SettingsProvider {

    // MARK:- Dependency
    private let settingsAPI: SettingsAPI
    private let cityProvider: CityProvider
    private let userProvider: UserProvider

    // Provider variable
    let settings: Variable<Settings>

    init(
        locationService: LocationService = locationServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        , userProvider: UserProvider = userProviderDefault
        , settingsAPI: SettingsAPI = SettingsAPIDefault()
        ) {
        self.settingsAPI = settingsAPI
        self.cityProvider = cityProvider
        self.userProvider = userProvider

        self.settings = { () -> Variable<Settings> in
            if let cashedSettings = SettingsProviderDefault.loadCasheForSettings() { // If there's cache then use it
                return Variable(cashedSettings)
            } else { // Otherwise, use the default value
                return Variable(Settings.defaultValue)
            }
        }()

        super.init()

        // Cache the locationDeducedCity city
        settings
            .asObservable()
            .subscribeNext { (settings: Settings) in
                SettingsProviderDefault.cashe(settings: settings)
            }.addDisposableTo(disposeBag)

        // Whenever a the city or the user change, update the settings
        Observable
            .combineLatest(
                cityProvider.currentCity.asObservable()
                , userProvider.currentUser.asObservable()) { (_, _) -> Void in
                return ()
            }
            .debounce(1, scheduler: ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background)) // Sometimes the city and the user are updated at the same time like in the case of logout and login, so we ignore the changes that are within a short period
            .subscribeNext { [weak self] _ in
                self?.updateSettings()
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK:- API
extension SettingsProviderDefault {
    func updateSettings() {
        let buildNumber = app.buildNumber
        let citySlug = self.cityProvider.currentCity.value?.slug
        let requestPayload = SettingsAPIRequestPayload(buildNumber: buildNumber, citySlug: citySlug)

        settingsAPI
            .updateSettings(withRequestPayload: requestPayload)
            .trackActivity(activityIndicator)
            .map { (settingsAPIResponsePayload: SettingsAPIResponsePayload) -> Settings in
                return settingsAPIResponsePayload.settings
            }
            .bindTo(settings) // Start emitting immidiatly
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Cashe
extension SettingsProviderDefault {

    private final class func cashe(settings settings: Settings) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(settings)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.SettingsProviderDefault).settings")
    }

    private final class func loadCasheForSettings() -> Settings? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.SettingsProviderDefault).settings") as? NSData else {
            return nil
        }

        guard let settings = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Settings else {
            clearCasheForSettings() // Cought curropted data!
            return nil
        }

        return settings
    }

    private final class func clearCasheForSettings() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                nil, forKey: "\(literal.SettingsProviderDefault).settings")
    }
}
