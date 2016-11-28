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

final class HomeFeaturedOfferTableViewCellViewModel: ViewModel {
    // MARK:- Dependency
    private let addFavoriteOutletAPI: AddFavoriteOutletAPI
    private let deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI
    private let locationService: LocationService
    private let favoriteOutletModel: FavoriteOutletModel
    private let userProvider: UserProviderDefault

    // MARK:- Outlet
    let title: Driver<String>
    let companyName: Driver<String>
    let outletName: Driver<String>
    let activityImage: Driver<NSURL?>
    let originalPrice: Driver<String>
    let officialPrice: Driver<String>
    let featuredText: Driver<String>

    // MARK:- Input
    let featuredListing: ListingType

    // MARK:-
    let favoritedId = Variable(0)

    // MARK: Signal
    let openOfferButtonDidTap = PublishSubject<()>()

    init(
        featuredListing: ListingType
        , addFavoriteOutletAPI: AddFavoriteOutletAPI = AddFavoriteOutletAPIDefault()
        , deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI = DeleteFavoriteOutletAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , favoriteOutletModel: FavoriteOutletModel = favoriteOutletModelDefault
        , userProvider: UserProviderDefault = userProviderDefault
        ) {
        self.featuredListing = featuredListing
        self.favoritedId.value = featuredListing.outlet.favoriteId
        self.locationService = locationService
        self.addFavoriteOutletAPI = addFavoriteOutletAPI
        self.deleteFavoriteOutletAPI = deleteFavoriteOutletAPI
        self.favoriteOutletModel = favoriteOutletModel
        self.userProvider = userProvider

        self.featuredText = Driver.of(featuredListing.featuredLabel.emptyOnNil())
        self.title = Driver.of(featuredListing.name)
        self.companyName = Driver.of(featuredListing.company.name)
        self.outletName = Driver.of(featuredListing.outlet.name)
        self.activityImage = Driver.of(featuredListing.featuredImage)
        self.officialPrice = Driver.of(featuredListing.purchaseDetails.discountPriceUserVisible)
        if (featuredListing.purchaseDetails.savingsUserVisible != nil) {
            self.originalPrice = Driver.of(featuredListing.purchaseDetails.originalPriceUserVisible)
        } else {
            self.originalPrice = Driver.of("")
        }

        super.init()

        // TAG: Thanh
        // TODO: Test this and remove the type inferal
        userProvider
            .currentUser
            .asObservable()
            .map {$0.isGuest}
            .skip(1)
            .distinctUntilChanged()
            .subscribeNext { [weak self] in
                if !$0 {
                    self?.addFavoriteOutlet()
                }
            }
            .addDisposableTo(disposeBag)

        openOfferButtonDidTap
            .subscribeNext { [weak self] _ in
                guard let strongSelf = self else { return }
                let vm = ListingViewModel(listingId: strongSelf.featuredListing.id, outletId: strongSelf.featuredListing.outlet.id, functionality: Variable(ListingViewModelFunctionality.Initiate()))
                let vc = ListingViewController.build(vm)
                strongSelf.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    viewController.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .addDisposableTo(disposeBag)

    }

    func listenToFavoriteChange() {
        self.favoriteOutletModel.getFavoriteOutlet()
            .filter {
                [weak self] (newOutlet) in
                return newOutlet == self?.featuredListing.outlet
            }
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (newOutlet) in
                self?.featuredListing.outlet.favoriteId = newOutlet.favoriteId
                self?.favoritedId.value = newOutlet.favoriteId
            }.addDisposableTo(disposeBag)
    }

    func didTapAddFavoriteOutlet() {
        if userProvider.currentUser.value.isGuest {
            let vm = EnterPhoneNumberViewControllerViewModel(enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality.LoginAGuestUser)
            let vc = EnterPhoneNumberViewController.build(vm)
            let nvc = RootNavigationController.build(RootNavigationViewModel())
            nvc.setViewControllers([vc], animated: false)
            lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                viewController.tabBarController?.presentViewController(nvc, animated: true, completion: nil)
            })
        } else {
            let analyticsModel = HomeAnalyticsModel(listing: self.featuredListing)
            analyticsModel.addToFavorite.sendToMoEngage()
            addFavoriteOutlet()
        }
    }

    func addFavoriteOutlet() {

        let addFavoriteOutletAPIRequestPayload = AddFavoriteOutletAPIRequestPayload(outletId: featuredListing.outlet.id)

        _ = addFavoriteOutletAPI.addFavoriteOutlet(withRequestPayload: addFavoriteOutletAPIRequestPayload)
            .subscribe(
                onNext: { [weak self](addFavoriteOutletAPIResponsePayload) in
                    guard let outlet = self?.featuredListing.outlet else { return }
                    outlet.favoriteId = addFavoriteOutletAPIResponsePayload.favourateId
                    self?.favoritedId.value = addFavoriteOutletAPIResponsePayload.favourateId
                    self?.favoriteOutletModel.favoriteChanged(outlet)
                }, onError: {
                    [weak self] (error) in
                    self?.favoritedId.value = 0
                }).addDisposableTo(disposeBag)
    }

    func deleteFavoriteOutlet() {

        let deleteFavoriteOutletAPIRequestPayload = DeleteFavoriteOutletAPIRequestPayload(outletId: featuredListing.outlet.favoriteId)

        _ = deleteFavoriteOutletAPI.deleteFavoriteOutlet(withRequestPayload: deleteFavoriteOutletAPIRequestPayload)
            .subscribe(
                onNext: {
                    [weak self](addFavoriteOutletAPIResponsePayload) in
                    guard let outlet = self?.featuredListing.outlet else { return }
                    outlet.favoriteId = 0
                    self?.favoritedId.value = 0
                    self?.favoriteOutletModel.favoriteChanged(outlet)
                }
                ,onError: {
                    [weak self] (error: ErrorType) in
                    self?.favoritedId.value = (self?.featuredListing.outlet.favoriteId)!
                }
            ).addDisposableTo(disposeBag)
    }
}
