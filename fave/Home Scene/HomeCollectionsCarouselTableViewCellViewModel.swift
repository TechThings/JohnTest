//
//  HomeCollectionsCarouselTableViewCellViewModel.swift
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
 *  HomeCollectionsCarouselTableViewCellViewModel
 */
final class HomeCollectionsCarouselTableViewCellViewModel: ViewModel {

    // MARK:- Dependency
    private let listingsCollectionsAPI: ListingsCollectionsAPI

    private var parameters: [String: AnyObject]?

    // MARK- Output
    let sectionModel: Driver<HomeSection?>
    let listingsCollections = Variable([ListingsCollection]())
    let activityIndicatorHidden = Variable(false)

    init(
        sectionModel: HomeSection,
        listingsCollectionsAPI: ListingsCollectionsAPI = ListingsCollectionsAPIDefault()
        ) {
        self.listingsCollectionsAPI = listingsCollectionsAPI
        self.parameters = sectionModel.parameters
        self.sectionModel = Driver.of(sectionModel)

        super.init()
    }

    func didSelectItemAtIndex(index: Int) {
        let id = listingsCollections.value[index].id
        let vm = ListingsCollectionViewControllerViewModel(collectionId: id)
        let vc = ListingsCollectionViewController.build(vm)

        lightHouseService
        .navigate
        .onNext { (viewController) in
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func viewAllItems() {
        let vm = ListingsCollectionsViewControllerViewModel()
        let vc = ListingsCollectionsViewController.build(vm)

        lightHouseService
        .navigate
        .onNext { (viewController) in
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func requestData() -> Observable<ResponsePayload> {

        let response = listingsCollectionsAPI.listingsCollections(withParameter: parameters)

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError { [weak self] (error: ErrorType) in
                self?.activityIndicatorHidden.value = true
            }
            .subscribeNext { [weak self]  (listingsCollectionsAPIResponsePayload: ListingsCollectionsAPIResponsePayload) in
                self?.activityIndicatorHidden.value = true
                self?.listingsCollections.value = listingsCollectionsAPIResponsePayload.listingsCollections
            }
            .addDisposableTo(disposeBag)

        let result = response
            .map { (listingsCollectionsAPIResponsePayload: ListingsCollectionsAPIResponsePayload) -> ResponsePayload in
            return listingsCollectionsAPIResponsePayload as ResponsePayload
        }

        return result
    }

}

// MARK:- Refreshable
extension HomeCollectionsCarouselTableViewCellViewModel: Refreshable {

    func refresh() {
        self.activityIndicatorHidden.value = false
        requestData()
    }
}
