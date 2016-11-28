//
//  ListingOutletTableViewCellViewModel.swift
//  KFIT
//
//  Created by Nazih Shoura on 14/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa

final class ListingOutletTableViewCellViewModel: ViewModel {

    // MARK:- Dependency
    let addFavoriteOutletAPI: AddFavoriteOutletAPI
    let deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI
    let locationService: LocationService
    let favoriteOutletModel: FavoriteOutletModel
    let userProvider: UserProviderDefault

    // Initial
    let partnerProfileImageURL = Variable<NSURL?>(nil)

    let partnerName = Variable("")
    let outletName = Variable("")
    let outletDistance = Variable("")

    let favoritedId = Variable(0)

    let partnerAverageRatingText        = Variable("")
    let partnerAverageRatingWidth       = Variable<CGFloat>(0)
    let partnerAverageRatingRight       = Variable<CGFloat>(0)
    let partnetAverageRatingFont        = UIFont.systemFontOfSize(10)

    let partnerFavoritedCountText       = Variable("")
    let partnerFavoritedCountWidth      = Variable<CGFloat>(0)
    let partnerFavoritedCountRight      = Variable<CGFloat>(0)
    let partnetFavoritedCountFont       = UIFont.systemFontOfSize(12)

    let partnerOffersCountText          = Variable("")
    let partnerOffersCountWidth         = Variable<CGFloat>(0)
    let partnerOffersCountFont          = UIFont.systemFontOfSize(12)
    let distanceHidden: Driver<Bool>
    let outletSearch: Outlet

    init(
        outletSearch: Outlet
        , addFavoriteOutletAPI: AddFavoriteOutletAPI = AddFavoriteOutletAPIDefault()
        , deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI = DeleteFavoriteOutletAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , favoriteOutletModel: FavoriteOutletModel = favoriteOutletModelDefault
        , userProvider: UserProviderDefault = userProviderDefault
        ) {
        self.locationService = locationService
        self.addFavoriteOutletAPI = addFavoriteOutletAPI
        self.deleteFavoriteOutletAPI = deleteFavoriteOutletAPI
        self.favoriteOutletModel = favoriteOutletModel
        self.userProvider = userProvider
        self.distanceHidden = { () -> Driver<Bool> in
            guard let type = outletSearch.company?.companyType else { return Driver.of(false) }
            return Driver.of(type == .online)
        }()

        self.outletSearch = outletSearch
        super.init()

        partnerProfileImageURL.value = outletSearch.company?.profileIconImageURL
        if let companyName = outletSearch.company?.name {
            partnerName.value = companyName
        }
        outletName.value = outletSearch.name
        favoritedId.value = outletSearch.favoriteId

        if let distance = outletSearch.distanceKM?.format("0.2") {
            outletDistance.value = ("\(distance) km")
        }

        if let average = outletSearch.company?.averageRating where average > 3.0 {
            partnerAverageRatingWidth.value = 38
            partnerAverageRatingRight.value = 9
            partnerAverageRatingText.value = average.format("0.1")
        } else {
            partnerAverageRatingWidth.value = 0
            partnerAverageRatingRight.value = 0
            partnerAverageRatingText.value = ""
        }

        let favoritedCount = outletSearch.favoritedCount
        if favoritedCount == 0 {
            partnerFavoritedCountWidth.value = 0
            partnerFavoritedCountRight.value = 0
            partnerFavoritedCountText.value = ""
        } else {
            partnerFavoritedCountRight.value = 2
            let text: String = favoritedCount == 1 ? "\(favoritedCount) fave" : "\(favoritedCount) faves"
            partnerFavoritedCountWidth.value = text.widthWithConstrainedHeight(21, font:partnetFavoritedCountFont) + 20
            partnerFavoritedCountText.value = text
        }

        let offersCount = outletSearch.offersCount
        if offersCount == 0 {
            partnerOffersCountWidth.value = 0
            partnerOffersCountText.value = ""
        } else {
            let text: String = offersCount == 1 ? "\(offersCount) \(NSLocalizedString("offer", comment: ""))" : "\(offersCount) \(NSLocalizedString("partner_detail_offers_text", comment: ""))"

            partnerOffersCountWidth.value = text.widthWithConstrainedHeight(21, font:partnerOffersCountFont) + 20
            partnerOffersCountText.value = text
        }
    }

    func listenToFavoriteChange() {
        self.favoriteOutletModel.getFavoriteOutlet()
            .filter {
                [weak self] (newOutlet) in
                return newOutlet == self?.outletSearch
            }
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (newOutlet) in
                self?.outletSearch.favoriteId = newOutlet.favoriteId
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
        let addFavoriteOutletAPIRequestPayload = AddFavoriteOutletAPIRequestPayload(outletId: outletSearch.id)

        _ = addFavoriteOutletAPI.addFavoriteOutlet(withRequestPayload: addFavoriteOutletAPIRequestPayload).subscribe(
            onNext: { [weak self](addFavoriteOutletAPIResponsePayload) in
                guard let outlet = self?.outletSearch else { return }

                outlet.favoriteId = addFavoriteOutletAPIResponsePayload.favourateId
                self?.favoritedId.value = addFavoriteOutletAPIResponsePayload.favourateId
                self?.favoriteOutletModel.favoriteChanged(outlet)
            }, onError: {
                [weak self] (error) in
                let error = error as NSError
                self?.lightHouseService.navigate.onNext { (viewController) in
                    let alertController = UIAlertController.alertController(forError: error)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
                self?.favoritedId.value = 0
            }).addDisposableTo(disposeBag)
    }

    func deleteFavoriteOutlet() {

        let deleteFavoriteOutletAPIRequestPayload = DeleteFavoriteOutletAPIRequestPayload(outletId: outletSearch.favoriteId)

        _ = deleteFavoriteOutletAPI.deleteFavoriteOutlet(withRequestPayload: deleteFavoriteOutletAPIRequestPayload)
            .subscribe(
                onNext: {
                    [weak self](addFavoriteOutletAPIResponsePayload) in
                    guard let outlet = self?.outletSearch else { return }

                    outlet.favoriteId = 0
                    self?.favoritedId.value = 0
                    self?.favoriteOutletModel.favoriteChanged(outlet)
                }
                , onError: {
                    [weak self] (error) in
                    guard let strongSelf = self else { return }
                    strongSelf.favoritedId.value = (strongSelf.outletSearch.favoriteId)
                }
            ).addDisposableTo(disposeBag)
    }

}
