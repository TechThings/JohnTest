//
//  HomePartnersCarouselTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  HomePartnersCarouselTableViewCellViewModel
 */
final class HomePartnersCarouselTableViewCellViewModel: ViewModel {

    // MARK:- Dependency
    private let outletsSearchAPI: OutletsSearchAPI
    private let locationService: LocationService

    // TAG: Thanh
    // This code doesn't smell nice!
    private var parameters: [String: AnyObject]

    // MARK- Output
    let sectionModel: Driver<HomeSection?>
    let outlets = Variable<[Outlet]>([Outlet]())
    let activityIndicatorHidden = Variable(false)

    init(
        sectionModel: HomeSection,
        outletsSearchAPI: OutletsSearchAPI = OutletsSearchAPIDefault(),
        locationService: LocationService = locationServiceDefault
        ) {
        self.parameters = sectionModel.parameters
        self.outletsSearchAPI = outletsSearchAPI
        self.locationService = locationService
        self.sectionModel = Driver.of(sectionModel)

        super.init()

        if let location = locationService.currentLocation.value {
            let latitudeString = String(location.coordinate.latitude)
            let longitudeString = String(location.coordinate.longitude)
            self.parameters["latitude"] = latitudeString
            self.parameters["longitude"] = longitudeString
        }
    }

    func didSelectItemAtIndex(index: Int) {
        if let company = outlets.value[index].company {
            let companyId = company.id
            let outletId = outlets.value[index].id
            let vm = OutletViewControllerViewModel(outletId: outletId, companyId: companyId)
            let vc = OutletViewController.build(vm)
            lightHouseService.navigate.onNext { (viewController: UIViewController) in
                viewController.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func viewAllItems() {
        let vm = OutletsSearchViewModel()
        let vc = OutletsSearchViewController.build(vm)
        lightHouseService.navigate.onNext { (viewController: UIViewController) in
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func requestData() -> Observable<ResponsePayload> {
        let response = outletsSearchAPI.searchOutletsFromDict(parameters: parameters)

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError { [weak self] (error: ErrorType) in
                self?.activityIndicatorHidden.value = true
            }
            .subscribeNext { [weak self]  (outletsSearchResponsePayload: OutletsSearchResponsePayload) in
                self?.outlets.value = outletsSearchResponsePayload.outlets
                self?.activityIndicatorHidden.value = true
            }
            .addDisposableTo(disposeBag)

        let result = response
            .map { (outletsSearchResponsePayload: OutletsSearchResponsePayload) -> ResponsePayload in
                return outletsSearchResponsePayload as ResponsePayload
        }

        return result
    }
}

// MARK:- Refreshable
extension HomePartnersCarouselTableViewCellViewModel: Refreshable {
    func refresh() {
        self.activityIndicatorHidden.value = false
        requestData()
    }
}
