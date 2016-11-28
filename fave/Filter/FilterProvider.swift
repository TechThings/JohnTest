//
//  FilterProvider.swift
//  fave
//
//  Created by Michael Cheah on 7/7/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol FilterProvider: Refreshable, Cachable {
    var headerFilter: Variable<[Category]?> { get }
    var currentFilter: Variable<[Category]?> { get }
    func getCategories() -> Observable<[Category]>
}

final class FilterProviderDefault: Provider, FilterProvider {
    // MARK:- Dependency
    let filterAPI: FiltersAPI
    let cityProvider: CityProvider

    // MARK:- Provided variables
    let currentFilter: Variable<[Category]?> = Variable(nil)
    let headerFilter: Variable<[Category]?> = Variable(nil)

    init(filterAPI: FiltersAPI = FiltersAPIDefault(),
         cityProvider: CityProvider = cityProviderDefault) {
        self.filterAPI = filterAPI
        self.cityProvider = cityProvider
        super.init()

        // Disable Filter
        cityProvider
            .currentCity
            .asObservable()
            .filterNil()
            .subscribeNext {
                [weak self] _ in
                // Get this from API
                self?.currentFilter.value = nil
                self?.headerFilter.value = nil
                self?.refresh()
            }.addDisposableTo(disposeBag)
    }

    func getCategories() -> Observable<[Category]> {
        let filterAPIRequestPayload = FiltersAPIRequestPayload()
        let requestObservalbe = filterAPI
            .getFilters(withRequestPayload: filterAPIRequestPayload)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .map({ (filtersAPIResponsePayload: FiltersAPIResponsePayload) -> [Category] in
                return filtersAPIResponsePayload.categories
            })
            .doOnNext { [weak self] (categories: [Category]) in
                self?.currentFilter.value = categories

                let headerCategories = categories.filter({ (category) -> Bool in
                    return category.homeScreen
                })
                self?.headerFilter.value = headerCategories
        }
        return requestObservalbe
    }
}

extension FilterProviderDefault {
    func refresh() {
        // Refresh the provided variables
        let filterAPIRequestPayload = FiltersAPIRequestPayload()

        filterAPI
            .getFilters(withRequestPayload: filterAPIRequestPayload)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(onNext: {
                [weak self] (filterAPIResponsePayload: FiltersAPIResponsePayload) in
                let categories = filterAPIResponsePayload.categories
                self?.currentFilter.value = categories

                let headerCategories = categories.filter({ (category) -> Bool in
                    return category.homeScreen
                })
                self?.headerFilter.value = headerCategories

                }, onError: {
                    (error) in
                    print("Failed to Fetch Filter")
            }).addDisposableTo(disposeBag)
    }
}

enum FilterProviderError: DescribableError {
    case FiltersCouldNotBeObtained

    var description: String {
        switch self {
        case .FiltersCouldNotBeObtained:
            return "Filters Could Not Be Obtained"
        }
    }

    var userVisibleDescription: String {
        switch self {
        case .FiltersCouldNotBeObtained:
            return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }
}
