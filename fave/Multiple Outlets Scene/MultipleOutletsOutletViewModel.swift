//
//  MultipleOutletsOutletViewModel.swift
//  FAVE
//
//  Created by Syahmi Ismail on 19/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MultipleOutletsOutletViewModel: ViewModel {
    // MARK:- Dependency
    let addFavoriteOutletAPI: AddFavoriteOutletAPI
    let deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI
    let favoriteOutletModel: FavoriteOutletModel
    let userProvider: UserProviderDefault

    // MARK- Output
    let outletName: Driver<String>
    let outletLocation: Driver<String>
    let favesString: Driver<String>
    let favesHidden: Driver<Bool>
    let offerString: Driver<String>
    let offerHidden: Driver<Bool>
    let favoritedId = Variable(0)
    let listing: ListingType
    let outlet: Outlet
    let favoritedButtonImage: Driver<UIImage?>

    init(
        listing: ListingType
        , outlet: Outlet
        , addFavoriteOutletAPI: AddFavoriteOutletAPI       = AddFavoriteOutletAPIDefault()
        , deleteFavoriteOutletAPI: DeleteFavoriteOutletAPI = DeleteFavoriteOutletAPIDefault()
        , favoriteOutletModel: FavoriteOutletModel         = favoriteOutletModelDefault
        , userProvider: UserProviderDefault                = userProviderDefault
        ) {
        self.listing                 = listing
        self.outlet                 = outlet
        self.favoritedId.value       = outlet.favoriteId
        self.addFavoriteOutletAPI    = addFavoriteOutletAPI
        self.deleteFavoriteOutletAPI = deleteFavoriteOutletAPI
        self.favoriteOutletModel     = favoriteOutletModel
        self.userProvider            = userProvider

        self.outletName = Driver.of(outlet.name)

        if let outletAddress = outlet.address {
            self.outletLocation = Driver.of(outletAddress)
        } else {
            self.outletLocation = Driver.of("")
        }

        self.favoritedId.value = outlet.favoriteId
        self.favoritedButtonImage    = Driver.of(UIImage(named: outlet.favoriteId > 0 ? "ic_outlet_favourited_fill" : "ic_outlet_favourited_pink"))

       let favouriteCount = outlet.favoritedCount
        if favouriteCount >= 2 {
            self.favesString = Driver.of("\(favouriteCount) faves")
            self.favesHidden = Driver.of(false)
        } else if favouriteCount == 1 {
            self.favesString = Driver.of("\(favouriteCount) fave")
            self.favesHidden = Driver.of(false)
        } else {
            self.favesString = Driver.of("")
            self.favesHidden = Driver.of(true)
        }

        let offersCount = outlet.offersCount
        if offersCount >= 2 {
            self.offerString = Driver.of("\(offersCount) \(NSLocalizedString("partner_detail_offers_text", comment: ""))")
            self.offerHidden = Driver.of(false)
        } else if offersCount == 1 {
            self.offerString = Driver.of("\(offersCount) \(NSLocalizedString("offer", comment: ""))")
            self.offerHidden = Driver.of(false)
        } else {
            self.offerString = Driver.of("")
            self.offerHidden = Driver.of(true)
        }

        super.init()
    }

    // CC: Can not using UITableViewAutomateDimension.
    func calculateHeight() -> CGFloat {

        let cellHeightWithoutAdrress: CGFloat = 80

        if let address = outlet.address {
            let addressLabelHeight = address.heightWithConstrainedWidth(UIScreen.mainWidth - 90, font: UIFont.systemFontOfSize(15))
            return cellHeightWithoutAdrress + addressLabelHeight
        } else {
            return cellHeightWithoutAdrress
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

    func didTapDeleteFavoriteOutlet() {
        if userProvider.currentUser.value.isGuest {
            requestSignIn()
        } else {
            deleteFavoriteOutlet()
        }
    }

    func deleteFavoriteOutlet() {

        let deleteFavoriteOutletAPIRequestPayload = DeleteFavoriteOutletAPIRequestPayload(outletId: self.outlet.favoriteId)

        _ = deleteFavoriteOutletAPI
            .deleteFavoriteOutlet(withRequestPayload: deleteFavoriteOutletAPIRequestPayload)
            .subscribe(
                onNext: {
                    [weak self](addFavoriteOutletAPIResponsePayload) in
                    guard let outlet = self?.outlet else { return }
                    outlet.favoriteId = 0
                    self?.favoritedId.value = 0
                    self?.favoriteOutletModel.favoriteChanged(outlet)
                }
                ,onError: {
                    [weak self] (error) in
                    self?.favoritedId.value = (self?.outlet.favoriteId)!
                }
            ).addDisposableTo(disposeBag)
    }

}
