//
//  MoreViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ZendeskSDK

/**
 *  @author Nazih Shoura
 *
 *  MoreViewModel
 */
final class MoreViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    let userProvider: UserProvider
    let assetProvider: AssetProvider

    // MARK- Output
    let moreTableViewCellViewModels: Variable<[MoreTableViewCellViewModel]> = Variable([MoreTableViewCellViewModel]())
    let isCurrentUserAguest = Variable(false)

    init(
        userProvider: UserProvider = userProviderDefault
        , assetProvider: AssetProvider = assetProviderDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.userProvider = userProvider
        self.assetProvider = assetProvider
        super.init()
        refresh()
    }
}

// MARK:- Refreshable
extension MoreViewModel: Refreshable {
    func refresh() {
        var viewModels = [MoreTableViewCellViewModel]()

        let accountTableViewCellViewModel = MoreTableViewCellViewModel(iconImage: UIImage(named: "ic_more_account")!, title: NSLocalizedString("more_profile_title_text", comment: ""), detail: NSLocalizedString("view_your_account_details", comment: "")) {
            () -> (ViewControllerPresentingStyle) in
            let vc = UserProfileViewController.build(UserProfileViewControllerViewModel())
            vc.hidesBottomBarWhenPushed = true
            return (viewController: vc, presentationStyle: PresentationStyle.Push)
        }
        viewModels.append(accountTableViewCellViewModel)

        let paymentTableViewCellViewModel = MoreTableViewCellViewModel(iconImage: UIImage(named: "ic_more_payments")!, title: NSLocalizedString("more_payment_title_text", comment: ""), detail: self.assetProvider.textAssest.value.paymentDescriptionText) {
            () -> (ViewControllerPresentingStyle) in
            let vc = PaymentViewController.build(PaymentViewModel())
            vc.hidesBottomBarWhenPushed = true
            return (viewController: vc, presentationStyle: PresentationStyle.Push)
        }
        viewModels.append(paymentTableViewCellViewModel)

        let creditTableViewCellViewModel = MoreTableViewCellViewModel(iconImage: UIImage(named: "ic_more_credit")!, title: NSLocalizedString("credits", comment: ""), detail: NSLocalizedString("more_credit_description_text", comment: "")) {
            () -> (ViewControllerPresentingStyle) in
            let vc = CreditViewController.build(CreditViewModel())
            vc.hidesBottomBarWhenPushed = true
            return (viewController: vc, presentationStyle: PresentationStyle.Push)
        }
        viewModels.append(creditTableViewCellViewModel)

        let promoTableViewCellViewModel = MoreTableViewCellViewModel(iconImage: UIImage(named: "ic_more_promo")!, title: NSLocalizedString("getting_started_promo_code_text", comment: ""), detail: NSLocalizedString("get_extra_credits", comment: "")) {
            () -> (ViewControllerPresentingStyle) in
            let vc = PromoViewController.build(PromoViewModel())
            vc.hidesBottomBarWhenPushed = true
            return (viewController: vc, presentationStyle: PresentationStyle.Push)
        }
        viewModels.append(promoTableViewCellViewModel)

        let needHelpTableViewCellViewModel = MoreTableViewCellViewModel(iconImage: UIImage(named: "ic_more_help")!, title: NSLocalizedString("more_faq_title_text", comment: ""), detail: NSLocalizedString("more_faq_description_text", comment: "")) {
            () -> (ViewControllerPresentingStyle) in
            let vc = SupportViewController.build(SupportViewModel())
            vc.hidesBottomBarWhenPushed = true
            return (viewController: vc, presentationStyle: PresentationStyle.Push)
        }
        viewModels.append(needHelpTableViewCellViewModel)

        let aboutUsTableViewCellViewModel = MoreTableViewCellViewModel(iconImage: UIImage(named: "ic_more_about")!, title: NSLocalizedString("more_about_title_text", comment: ""), detail: NSLocalizedString("more_about_description_text", comment: "")) { () -> (ViewControllerPresentingStyle) in
            let vc = AboutUsViewController.build(AboutUsViewControllerViewModel())
            vc.hidesBottomBarWhenPushed = true
            return (viewController: vc, presentationStyle: PresentationStyle.Push)
        }
        viewModels.append(aboutUsTableViewCellViewModel)

        moreTableViewCellViewModels.value = viewModels
    }
}
