//
//  ListingsGroupedOutletTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  ListingsGroupedOutletTableViewCellViewModel
 */
final class ListingsGroupedOutletTableViewCellViewModel: ViewModel {

    // MARK:- Dependency
    private let addFavoriteOutletAPI: AddFavoriteOutletAPI
    private let deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI
    let favoriteOutletModel: FavoriteOutletModel
    let userProvider: UserProviderDefault

    // MARK:- Output
    let partnerName: Driver<String>
    let outletName: Driver<String>

    let ratingText: Driver<String>
    let ratingHidden: Driver<Bool>

    let favoritedCountText: Driver<String>
    let favoritedCountHidden: Driver<Bool>

    let outletDistance: Driver<String>
    let outletDistanceHidden: Driver<Bool>

    let favoritedId = Variable(0)
    let outlet: Outlet

    init(
        outlet: Outlet
        , addFavoriteOutletAPI: AddFavoriteOutletAPI = AddFavoriteOutletAPIDefault()
        , deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI = DeleteFavoriteOutletAPIDefault()
        , favoriteOutletModel: FavoriteOutletModel = favoriteOutletModelDefault
        , userProvider: UserProviderDefault = userProviderDefault
        ) {
        self.addFavoriteOutletAPI = addFavoriteOutletAPI
        self.deleteFavoriteOutletAPI = deleteFavoriteOutletAPI
        self.favoriteOutletModel = favoriteOutletModel
        self.userProvider = userProvider

        self.outlet = outlet

        self.outletName = Driver.of(outlet.name)

        let companyName = { () -> String in
            guard let name = outlet.company?.name else {
                return ""
            }
            return name
        }()
        self.partnerName = Driver.of(companyName)

        if let rating = outlet.company?.averageRating where rating > 3.0 {
            self.ratingText = Driver.of(String(rating))
            self.ratingHidden = Driver.of(false)
        } else {
            self.ratingText = Driver.of("")
            self.ratingHidden = Driver.of(true)
        }

        let favoriteCount = outlet.favoritedCount
        if favoriteCount > 0 {
            if favoriteCount > 1 {
                self.favoritedCountText = Driver.of("\(favoriteCount) faves")
            } else {
                self.favoritedCountText = Driver.of("\(favoriteCount) fave")
            }
            self.favoritedCountHidden = Driver.of(false)
        } else {
            self.favoritedCountText = Driver.of("")
            self.favoritedCountHidden = Driver.of(true)
        }

        if let distance = outlet.distanceKM?.format("0.1") {
            self.outletDistance = Driver.of("\(distance) km")
        } else {
            self.outletDistance = Driver.of("")
        }

        if let companyType = outlet.company?.companyType where companyType == .online {
            self.outletDistanceHidden = Driver.of(true)
        } else {
            self.outletDistanceHidden = Driver.of(false)
        }

        favoritedId.value = outlet.favoriteId

        super.init()
    }

    func listenToFavoriteChange() {
        self.favoriteOutletModel.getFavoriteOutlet()
            .filter {
                [weak self] (newOutlet) in
                return newOutlet == self?.outlet
            }
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (newOutlet) in
                self?.outlet.favoriteId = newOutlet.favoriteId
                self?.favoritedId.value = newOutlet.favoriteId
            }.addDisposableTo(disposeBag)
    }

    func didTapAddFavoriteOutlet() {
        if userProvider.currentUser.value.isGuest {
            let vm = EnterPhoneNumberViewControllerViewModel(enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality.LoginAGuestUser)
            let vc = EnterPhoneNumberViewController.build(vm)
            let nvc = RootNavigationController.build(RootNavigationViewModel())
            nvc.setViewControllers([vc], animated: false)
            UIViewController.currentViewController?.presentViewController(nvc, animated: true, completion: nil)

        } else {
            addFavoriteOutlet()
        }
    }

    func addFavoriteOutlet() {
        let addFavoriteOutletAPIRequestPayload = AddFavoriteOutletAPIRequestPayload(outletId: outlet.id)

        _ = addFavoriteOutletAPI.addFavoriteOutlet(withRequestPayload: addFavoriteOutletAPIRequestPayload)
            .subscribe(
                onNext: { [weak self](addFavoriteOutletAPIResponsePayload) in
                    guard let outlet = self?.outlet else { return }
                    outlet.favoriteId = addFavoriteOutletAPIResponsePayload.favourateId
                    self?.favoritedId.value = addFavoriteOutletAPIResponsePayload.favourateId
                    self?.favoriteOutletModel.favoriteChanged(outlet)
                }, onError: {
                    [weak self] (error) in
                    self?.favoritedId.value = 0
                }).addDisposableTo(disposeBag)
    }

    func deleteFavoriteOutlet() {

        let deleteFavoriteOutletAPIRequestPayload = DeleteFavoriteOutletAPIRequestPayload(outletId: outlet.favoriteId)

        _ = deleteFavoriteOutletAPI.deleteFavoriteOutlet(withRequestPayload: deleteFavoriteOutletAPIRequestPayload)
            .subscribe(
                onNext: {
                    [weak self](addFavoriteOutletAPIResponsePayload) in

                    guard let outlet = self?.outlet else { return }
                    outlet.favoriteId = 0
                    self?.favoritedId.value = 0
                    self?.favoriteOutletModel.favoriteChanged(outlet)
                }
                , onError: {
                    [weak self] (error) in
                    self?.favoritedId.value = (self?.outlet.favoriteId)!
                }
            ).addDisposableTo(disposeBag)
    }
}
