//
//  HomeListingViewViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeListingViewViewModel: ViewModel {
    // MARK:- Dependency
    let addFavoriteOutletAPI: AddFavoriteOutletAPI
    let deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI
    let locationService: LocationService
    let favoriteOutletModel: FavoriteOutletModel
    let userProvider: UserProviderDefault

    // MARK:- ViewModel Initial State

    let activityName: Driver<String>
    let companyName: Driver<String>
    let totalOutlet: Driver<String>
    let averageRating: Driver<String>
    let averageRatingViewHidden: Driver<Bool>
    let activityImage: Driver<NSURL?>
    let distance: Driver<String>
    let distanceHidden: Driver<Bool>
    let distanceWidth: Driver<CGFloat>
    let originalPrice: Driver<String>
    let officialPrice: Driver<String>
    let favoritedButtonImage: Driver<UIImage?>

    let listing: ListingType
    let favoritedId = Variable(0)

    init(
        listing: ListingType
        , addFavoriteOutletAPI: AddFavoriteOutletAPI       = AddFavoriteOutletAPIDefault()
        , deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI = DeleteFavoriteOutletAPIDefault()
        , locationService: LocationService                 = locationServiceDefault
        , favoriteOutletModel: FavoriteOutletModel         = favoriteOutletModelDefault
        , userProvider: UserProviderDefault                = userProviderDefault
        ) {
        self.listing                 = listing
        self.favoritedId.value       = listing.outlet.favoriteId
        self.locationService         = locationService
        self.addFavoriteOutletAPI    = addFavoriteOutletAPI
        self.deleteFavoriteOutletAPI = deleteFavoriteOutletAPI
        self.favoriteOutletModel     = favoriteOutletModel
        self.userProvider            = userProvider
        self.averageRatingViewHidden = Driver.of(listing.company.averageRating <= 3.0)
        self.activityName            = Driver.of(listing.name)
        self.companyName             = Driver.of(listing.company.name)

        var outletName = listing.outlet.name
        if self.listing.company.companyType == .online {
            outletName = ""
        }
        if let totalRedeemableOutlets = listing.totalRedeemableOutlets where totalRedeemableOutlets > 1 {
            let remainRedeemableOutlets = totalRedeemableOutlets - 1
            if  remainRedeemableOutlets > 1 {
                self.totalOutlet      = Driver.of("\(outletName) and \(remainRedeemableOutlets) more locations")
            } else {
                self.totalOutlet      = Driver.of("\(outletName) and \(remainRedeemableOutlets) more location")
            }

        } else {
            self.totalOutlet            = Driver.of(outletName)
        }

        self.averageRating           = Driver.of(String(listing.company.averageRating))
        self.activityImage           = Driver.of(listing.featuredImage)
        let distanceString           = String(listing.outlet.distanceKM!.format("0.1")) + " km"
        self.distance                = Driver.of(distanceString)
        self.distanceHidden = { () -> Driver<Bool> in
            return Driver.of(listing.company.companyType == .online)
        }()

        self.distanceWidth           = Driver.of(distanceString.widthWithConstrainedHeight(21, font: UIFont.systemFontOfSize(11)) + 28)
        self.officialPrice           = Driver.of(listing.purchaseDetails.discountPriceUserVisible)
        if (listing.purchaseDetails.savingsUserVisible != nil) {
            self.originalPrice           = Driver.of(listing.purchaseDetails.originalPriceUserVisible)
        } else {
            self.originalPrice = Driver.of("")
        }
        self.favoritedButtonImage    = Driver.of(UIImage(named: listing.outlet.favoriteId > 0 ? "ic_outlet_favourited_fill" : "ic_outlet_favourited_white"))
        super.init()

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
        self.favoriteOutletModel.getFavoriteOutlet()
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

    func requestSignIn() {
        let vm = EnterPhoneNumberViewControllerViewModel(enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality.LoginAGuestUser)
        let vc = EnterPhoneNumberViewController.build(vm)
        let nvc = RootNavigationController.build(RootNavigationViewModel())
        nvc.setViewControllers([vc], animated: false)
        UIViewController.currentViewController?.presentViewController(nvc, animated: true, completion: nil)
    }

    func didTapAddFavoriteOutlet() {
        if userProvider.currentUser.value.isGuest {
            requestSignIn()
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

    func didTapDeleteFavoriteOutlet() {
        if userProvider.currentUser.value.isGuest {
            requestSignIn()
        } else {
            deleteFavoriteOutlet()
        }
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
