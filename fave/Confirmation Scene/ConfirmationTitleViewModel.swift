//
//  ConfirmationTitleViewModel.swift
//  fave
//
//  Created by Michael Cheah on 7/8/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  ConfirmationTitleViewModel
 */

final class ConfirmationTitleViewModel: ViewModel {
    // MARK- Output
    let activityName: Driver<String>
    let companyName: Driver<String>
    let featuredImage: Driver<NSURL?>
    let cancellationPolicy: Driver<String>
    let outletName: Driver<String>
    let redeemTime: Driver<String>
    let redeemTimeTitle: Driver<String>
    var favePromiseHidden: Driver<Bool>
    let multipleOutletsTitle: Driver<String>
    let multipleOutletsHidden: Driver<Bool>
    let listing: ListingType
    let didTapViewAllMultipleOutletsButton = PublishSubject<Void>()

    init(listing: ListingType!, classSession: ClassSession?) {
        self.listing = listing
        self.activityName = Driver.of(listing.name)
        self.companyName = Driver.of(listing.company.name)
        self.featuredImage = Driver.of(listing.featuredImage)
        self.favePromiseHidden = { () -> Driver<Bool> in
            if let showFavePromise = listing.showFavePromise {
                return Driver.of((showFavePromise == false))
            }
            return Driver.of(true)
        }()

        if let totalRedeemableOutlets = listing.totalRedeemableOutlets where totalRedeemableOutlets > 1 {
            self.multipleOutletsTitle = Driver.of("\(NSLocalizedString("purchase_detail_available_outlets_text", comment: "")) \(totalRedeemableOutlets) \(NSLocalizedString("locations", comment: ""))")
            self.multipleOutletsHidden = Driver.of(false)
        } else {
            self.multipleOutletsTitle = Driver.of("")
            self.multipleOutletsHidden = Driver.of(true)
        }

        if let address = listing.outlet.address {
            self.outletName = Driver.of(address)
        } else {
            self.outletName = Driver.of(listing.outlet.name)
        }

        if let listingOpenVoucher = listing as? ListingOpenVoucher,
            let voucher = listingOpenVoucher.voucherDetail,
            let startDate = voucher.validityStartDateTime.PromoDateString,
            let endDate = voucher.validityEndDateTime.PromoDateString {

            self.redeemTimeTitle = Driver.of(NSLocalizedString("redeem_from", comment: ""))
            self.redeemTime = Driver.of("\(startDate) until \(endDate)")
            let cancellationPolicyText = "\(NSLocalizedString("receive_full_refund_in_fave_credit", comment: "")) \(voucher.refund_end_datetime.RefundEndDateString!)"
            self.cancellationPolicy = Driver.of(cancellationPolicyText)
        } else if let classSession = classSession {
            let detailsTime = classSession.startDateTime.shortTimeString()
                + " - " + classSession.endDateTime.shortTimeString() + ", " + classSession.startDateTime.PromoDateString!
            self.redeemTimeTitle = Driver.of(NSLocalizedString("confirmation_redeem_on_text", comment: ""))
            self.redeemTime = Driver.of(detailsTime)
            let cancellationPolicyText = "\(NSLocalizedString("receive_full_refund_in_fave_credit", comment: "")) \(classSession.earlyCancellationDate.RefundEndDateString!)"
            self.cancellationPolicy = Driver.of(cancellationPolicyText)
        } else {
            self.redeemTime = Driver.of("")
            self.redeemTimeTitle = Driver.of("")
            self.cancellationPolicy = Driver.of("")
        }

        super.init()

        didTapViewAllMultipleOutletsButton
            .subscribeNext { [weak self] () in
                self?.goToMultipleOutletsDetail()
            }.addDisposableTo(disposeBag)
    }

    func goToMultipleOutletsDetail() {
        let vc = MultipleOutletsViewController.build(MultipleOutletsViewControllerViewModel(listing: listing))
        let nvc = UINavigationController(rootViewController: vc)

        lightHouseService
            .navigate
            .onNext { (viewController) in
                viewController.presentViewController(nvc, animated: true, completion: nil)
        }
    }

    // MARK:- Life cycle
    deinit {

    }
}
