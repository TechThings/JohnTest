//
//  ReservationViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/4/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ReservationViewModel: ViewModel {
    let statusName = Variable("")
    let listingPhoto = Variable<NSURL?>(nil)
    let listingName = Variable("")
    let companyName = Variable("")
    let outletName = Variable("")
    let timeSlotDay = Variable("")
    let timeSlotTime = Variable("")
    let hideOpenVoucherView = Variable(false)
    let openVoucherText = Variable("")
    let statusColor: Driver<UIColor>
    let statusViewHidden: Driver<Bool>
    let statusTitle: Driver<String?>
    init(reservation: Reservation) {
        statusName.value = reservation.reservationState.UIString.uppercaseString
        listingPhoto.value = reservation.listingDetails.featuredImage
        listingName.value = reservation.listingDetails.name
        companyName.value = reservation.listingDetails.company.name
        let outletNameString = reservation.listingDetails.outlet.name
        if let totalRedeemableOutlets = reservation.listingDetails.totalRedeemableOutlets where totalRedeemableOutlets > 1 {
            let remainRedeemableOutlets = totalRedeemableOutlets - 1
            if remainRedeemableOutlets > 1 {
                outletName.value = "\(outletNameString) and \(remainRedeemableOutlets) more locations"
            } else {
                outletName.value = "\(outletNameString) and \(remainRedeemableOutlets) more location"
            }
        } else {
            outletName.value = outletNameString
        }
        timeSlotDay.value = reservation.reservationFromDateTime.PromoDateString!
        timeSlotTime.value = "\(reservation.reservationFromDateTime.time(.HourMinutePeriod)) - \(reservation.reservationToDateTime.time(.HourMinutePeriod))"
        hideOpenVoucherView.value = (reservation.listingDetails.option == ListingOption.TimeSlot)
        openVoucherText.value = "\(reservation.reservationFromDateTime.PromoDateString!) to \(reservation.reservationToDateTime.PromoDateString!)"

        statusViewHidden = { () -> Driver<Bool> in
            switch reservation.reservationState {
            case .Confirmed: return Driver.of(true)
            default: return Driver.of(false)
            }
        }()

        statusColor = { () -> Driver<UIColor> in
            switch reservation.reservationState {
            case .PendingPayment, .Expired, .Cancelled: return Driver.of(UIColor.favePink())
            default: return Driver.of(UIColor.faveBlue())
            }
        }()

        self.statusTitle = Driver.of(reservation.statusTitle?.uppercaseString)

        super.init()
    }
}
