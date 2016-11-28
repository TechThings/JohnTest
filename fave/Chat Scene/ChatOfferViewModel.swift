//
//  ChatOfferViewModel.swift
//  FAVE
//
//  Created by Michael Cheah on 8/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  ChatOfferViewModel
 */
final class ChatOfferViewModel: ViewModel {

    // MARK:- Dependency

    let rxAnalytics: RxAnalytics

    // MARK:- Variable

    //MARK:- Input
    let listing: ListingType

    // MARK:- Intermediate

    // MARK- Output
    let activityName: String
    let featureImage: NSURL?
    let originalPriceUserVisible: String?
    let finalPriceUserVisible: String?
    let companyName: String
    let outletName: String

    init(listing: ListingType, rxAnalytics: RxAnalytics = rxAnalyticsDefault) {
        self.listing = listing
        self.activityName = listing.name
        self.featureImage = listing.featuredImage

        self.finalPriceUserVisible = listing.purchaseDetails.finalPriceUserVisible
        if (listing.purchaseDetails.savingsUserVisible != nil) {
            self.originalPriceUserVisible = listing.purchaseDetails.originalPriceUserVisible
        } else {
            self.originalPriceUserVisible = nil
        }

        self.companyName = listing.company.name
        self.outletName = listing.outlet.name

        self.rxAnalytics = rxAnalytics
        super.init()
    }

    func onBuyButtonTap() {
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "buy", screenName: screenName.SCREEN_CONVERSATION)
        rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

        let vc = ListingViewController.build(ListingViewModel(listingId: listing.id, outletId: listing.outlet.id, functionality: Variable(ListingViewModelFunctionality.Initiate())))
        vc.hidesBottomBarWhenPushed = true

        self.lightHouseService
            .navigate
            .onNext { (viewController) in
                viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
