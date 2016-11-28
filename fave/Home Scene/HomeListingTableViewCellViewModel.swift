//
//  HomeActivitesCellViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeListingTableViewCellViewModel: ViewModel {
    // MARK:- Dependency
    let addFavoriteOutletAPI: AddFavoriteOutletAPI
    let deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI
    let locationService: LocationService
    let favoriteOutletModel: FavoriteOutletModel
    let userProvider: UserProviderDefault

    // MARK:- ViewModel Initial State

    let title = Variable("")
    let companyName = Variable("")
    let totalOutlet = Variable("")
    let averageRating = Variable("")
    let averageRatingViewHidden = Variable(false)
    let activityImage = Variable<NSURL?>(nil)
    let distance = Variable("")
    let distanceWidth = Variable<CGFloat>(0)
    let originalPrice = Variable("")
    let originalPriceHidden = Variable(false)
    let officialPriceWidth = Variable<CGFloat>(0)
    let officialPrice = Variable("")
    let distanceHidden: Driver<Bool>
    let listing: ListingType!
    let favoritedId = Variable(0)

    init(
        listing: ListingType
        , addFavoriteOutletAPI: AddFavoriteOutletAPI = AddFavoriteOutletAPIDefault()
        , deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI = DeleteFavoriteOutletAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , favoriteOutletModel: FavoriteOutletModel = favoriteOutletModelDefault
        , userProvider: UserProviderDefault = userProviderDefault
        ) {
        self.listing = listing
        self.favoritedId.value = listing.outlet.favoriteId
        self.locationService = locationService
        self.addFavoriteOutletAPI = addFavoriteOutletAPI
        self.deleteFavoriteOutletAPI = deleteFavoriteOutletAPI
        self.favoriteOutletModel = favoriteOutletModel
        self.userProvider = userProvider
        self.distanceHidden = { () -> Driver<Bool> in
            return Driver.of(listing.company.companyType == .online)
        }()

        super.init()

        title.value = listing.name
        companyName.value = listing.company.name

        var outletName = listing.outlet.name
        if self.listing.company.companyType == .online {
            outletName = ""
        }
        if let totalRedeemableOutletValue = listing.totalRedeemableOutlets where totalRedeemableOutletValue > 1 {
            let remainRedeemableOutlet = totalRedeemableOutletValue - 1
            if remainRedeemableOutlet > 1 {
                totalOutlet.value = ("\(outletName) & \(remainRedeemableOutlet) more locations")
            } else {
                totalOutlet.value = ("\(outletName) & \(remainRedeemableOutlet) more location")
            }
        } else {
            totalOutlet.value = outletName
        }
        averageRating.value = String(listing.company.averageRating)
        averageRatingViewHidden.value = listing.company.averageRating < 3.5
        activityImage.value = listing.featuredImage
        let distanceString = String(listing.outlet.distanceKM!.format("0.1"))
        distance.value = ("\(distanceString) km")
        distanceWidth.value = distance.value.widthWithConstrainedHeight(21, font: UIFont.systemFontOfSize(11)) + 28

        officialPrice.value = listing.purchaseDetails.discountPriceUserVisible
        officialPriceWidth.value = officialPrice.value.widthWithConstrainedHeight(18, font: UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)) + 2

        originalPrice.value = listing.purchaseDetails.originalPriceUserVisible
        originalPriceHidden.value = (listing.purchaseDetails.savingsUserVisible == nil)

        userProvider
            .currentUser
            .asObservable()
            .map { (currentUser: User) -> Bool in currentUser.isGuest }
            .skip(1)
            .distinctUntilChanged()
            .subscribeNext { [weak self] (isGuest: Bool) in
                if !isGuest {
                    self?.addFavoriteOutlet()
                }
            }.addDisposableTo(disposeBag)
    }

    func listenToFavoriteChange() {
        self.favoriteOutletModel
            .getFavoriteOutlet()
            .filter {
                [weak self] (newOutlet) in
                return newOutlet == self?.listing.outlet
            }
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (newOutlet) in
                self?.listing.outlet.favoriteId = newOutlet.favoriteId
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
            let analyticsModel = HomeAnalyticsModel(listing: listing)
            analyticsModel.addToFavorite.sendToMoEngage()
            addFavoriteOutlet()
        }
    }

    func addFavoriteOutlet() {

        let addFavoriteOutletAPIRequestPayload = AddFavoriteOutletAPIRequestPayload(outletId: listing.outlet.id)

        _ = addFavoriteOutletAPI.addFavoriteOutlet(withRequestPayload: addFavoriteOutletAPIRequestPayload)
            .subscribe(
                onNext: { [weak self](addFavoriteOutletAPIResponsePayload) in
                    guard let outlet = self?.listing.outlet else { return }
                    outlet.favoriteId = addFavoriteOutletAPIResponsePayload.favourateId
                    self?.favoritedId.value = addFavoriteOutletAPIResponsePayload.favourateId
                    self?.favoriteOutletModel.favoriteChanged(outlet)
                }, onError: {
                    [weak self] (error) in
                    self?.favoritedId.value = 0
                }).addDisposableTo(disposeBag)
    }

    func deleteFavoriteOutlet() {

        let deleteFavoriteOutletAPIRequestPayload = DeleteFavoriteOutletAPIRequestPayload(outletId: listing.outlet.favoriteId)

        _ = deleteFavoriteOutletAPI.deleteFavoriteOutlet(withRequestPayload: deleteFavoriteOutletAPIRequestPayload)
            .subscribe(
                onNext: {
                    [weak self](addFavoriteOutletAPIResponsePayload) in
                    guard let outlet = self?.listing.outlet else { return }
                    outlet.favoriteId = 0
                    self?.favoritedId.value = 0
                    self?.favoriteOutletModel.favoriteChanged(outlet)
                }
                ,onError: {
                    [weak self] (error) in
                    self?.favoritedId.value = (self?.listing.outlet.favoriteId)!
                }
            ).addDisposableTo(disposeBag)
    }
}
