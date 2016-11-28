//
//  OutletsSearchTableViewCellModel.swift
//  KFIT
//
//  Created by Nazih Shoura on 14/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa

protocol OutletsSearchTableViewCellModelDelegate: class {
    func pushViewController(viewController: UIViewController)
}

final class OutletsSearchTableViewCellModel: ViewModel {

    // MARK:- Dependency
    let addFavoriteOutletAPI: AddFavoriteOutletAPI
    let deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI
    let locationService: LocationService
    let favoriteOutletModel: FavoriteOutletModel
    let userProvider: UserProviderDefault

    // Initial
    let partnerProfileImageURL = Variable<NSURL?>(nil)

    // MARK:- Delegate
    weak var delegate: OutletsSearchTableViewCellModelDelegate?

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

    let outlet: Outlet
    let company: Company

    init(
        outlet: Outlet
        , company: Company
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

        self.outlet = outlet
        self.company = company
         self.distanceHidden = { () -> Driver<Bool> in
            return Driver.of(company.companyType == .online)
        }()

        super.init()

        partnerProfileImageURL.value = self.company.featuredImage
        partnerName.value = self.company.name
        outletName.value = outlet.name
        favoritedId.value = outlet.favoriteId

        if let distance = outlet.distanceKM?.format("0.2") {
            outletDistance.value = ("\(distance) KM")
        }

        let average = self.company.averageRating
        if average <= 3.0 {
            partnerAverageRatingWidth.value = 0
            partnerAverageRatingRight.value = 0
            partnerAverageRatingText.value = ""
        } else {
            partnerAverageRatingWidth.value = 36
            partnerAverageRatingRight.value = 8
            partnerAverageRatingText.value = average.format("0.1")
        }

        let favoritedCount = outlet.favoritedCount
        if favoritedCount == 0 {
            partnerFavoritedCountWidth.value = 0
            partnerFavoritedCountRight.value = 0
            partnerFavoritedCountText.value = ""
        } else {
            partnerFavoritedCountRight.value = 1

            let text = { () -> String in
                if favoritedCount == 1 {
                    return "\(favoritedCount) \(NSLocalizedString("fave", comment: ""))"
                } else {
                    return "\(favoritedCount) \(NSLocalizedString("faves", comment: ""))"
                }
            }()

            partnerFavoritedCountWidth.value = text.widthWithConstrainedHeight(21, font:partnetFavoritedCountFont) + 20
            partnerFavoritedCountText.value = text
        }

        let offersCount = outlet.offersCount
        if offersCount == 0 {
            partnerOffersCountWidth.value = 0
            partnerOffersCountText.value = ""
        } else {

            let text = { () -> String in
                if offersCount == 1 {
                    return "\(offersCount) \((NSLocalizedString("offer", comment: "")))"
                } else {
                    return "\(offersCount) \((NSLocalizedString("partner_detail_offers_text", comment: "")))"
                }
            }()

            partnerOffersCountWidth.value = text.widthWithConstrainedHeight(21, font:partnerOffersCountFont) + 20
            partnerOffersCountText.value = text
        }
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

    func showPartnerDetails() {
        let vc = OutletViewController.build(OutletViewControllerViewModel(outletId: self.outlet.id, companyId: self.company.id))
        vc.hidesBottomBarWhenPushed = true
        self.delegate?.pushViewController(vc)
    }

}
