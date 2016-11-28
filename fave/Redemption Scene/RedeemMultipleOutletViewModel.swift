//
//  RedeemMultipleOutletViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/17/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  RedeemMultipleOutletViewModel
 */
final class RedeemMultipleOutletViewModel: ViewModel {

    // MARK:- Dependency
    private let multipleOutletsAPI: MultipleOutletsAPI

    // MARK- Signal
    let cancelButtonDidTap = PublishSubject<Void>()
    let redeemButtonDidTap = PublishSubject<Void>()
    let selectedOutletId   = Variable<Int?> (nil)

    let outlets         = Variable<[Outlet]>([Outlet]())
    let listingId       = Variable<Int?>(nil)
    let tableViewHeight = Variable<CGFloat>(0.0)

    let redeemContentViewTopLimited: CGFloat      = 64.0
    let redeemContentViewBottomLimited: CGFloat   = 64.0
    let redeemOutletTableViewCellHeight: CGFloat = 50.0
    let tableViewTopCoordinate: CGFloat           = 175.0
    let tableViewBottomCoordinate: CGFloat        = 60.0

    init(
        multipleOutletsAPI: MultipleOutletsAPI = MultipleOutletsAPIDefault()
        ) {
        self.multipleOutletsAPI = multipleOutletsAPI
        super.init()

        listingId
            .asObservable()
            .filterNil()
            .subscribeNext { [weak self] (listingId) in
                self?.requestMultipleOutlet(listingId)
        }.addDisposableTo(disposeBag)
    }

    func calculateTableViewHeight(numberOfRow count: Int) -> CGFloat {
        if count <= 1 {
            return 0.0
        }

        let tableContentHeight = CGFloat(count) * redeemOutletTableViewCellHeight
        let maxHeight = UIScreen.mainHeight - redeemContentViewTopLimited - redeemContentViewBottomLimited - tableViewTopCoordinate - tableViewBottomCoordinate

        return min(tableContentHeight, maxHeight)
    }

    func requestMultipleOutlet(listingId: Int) {
        // CC: Should support paging
        let response = multipleOutletsAPI
            .getMultipleOutlets(withRequestPayload: MultipleOutletsAPIRequestPayload(page: nil, limit: 100, location: nil, listingId: listingId))

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError({ [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                })
            })
            .map({ (response: MultipleOutletsAPIResponsePayload) -> [Outlet] in
                response.outlets
            })
            .bindTo(outlets)
            .addDisposableTo(disposeBag)

        outlets
            .asObservable()
            .map { [weak self] (outlets) -> CGFloat in
                guard let strongSelf = self else {return 0}
                return strongSelf.calculateTableViewHeight(numberOfRow: outlets.count)
            }
            .bindTo(tableViewHeight)
            .addDisposableTo(disposeBag)

        outlets
            .asObservable()
            .filterEmpty()
            .take(1)
            .map { (outlets) -> Outlet in
                return outlets.first!
            }.map { (outlet) -> Int in
                return outlet.id
            }.bindTo(selectedOutletId)
            .addDisposableTo(disposeBag)
    }
}
