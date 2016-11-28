//
//  ReservationTimeSlotDetailsViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ReservationTimeSlotDetailsViewModel
 */
final class ReservationTimeSlotDetailsViewModel: ViewModel {

    // MARK:- Input
    let reservation: Reservation

    // MARK- Output
    // Static
    let dateStatic: Driver<String>
    let locationStatic: Driver<String> = Driver.of(NSLocalizedString("redeem_at", comment: ""))
    let paxStatic: Driver<String> = Driver.of(NSLocalizedString("pax", comment: ""))
    let timeStatic: Driver<String> = Driver.of(NSLocalizedString("my_fave_time_text", comment: ""))

    // Variable
    let reservationTime: Driver<String>
    let reservationDate: Driver<String>
    let location: Driver<String>
    let companyName: Driver<String>
    let isListingOpenVouture: Driver<Bool>
    init(
        reservation: Reservation
        ) {
        self.reservation = reservation
        reservationTime = Driver.of("\(reservation.reservationFromDateTime.time(.HourMinutePeriod)) - \(reservation.reservationToDateTime.time(.HourMinutePeriod))")
        if let totalRedeemableOutlets = reservation.listingDetails.totalRedeemableOutlets where totalRedeemableOutlets > 1 {
            let remainRedeemableOutlets = totalRedeemableOutlets - 1
            if remainRedeemableOutlets > 1 {
                location = Driver.of("\(reservation.listingDetails.outlet.name) and \(remainRedeemableOutlets) more locations")
            } else {
                location = Driver.of("\(reservation.listingDetails.outlet.name) and \(remainRedeemableOutlets) more location")
            }
        } else {
            location = Driver.of(reservation.listingDetails.outlet.address!)
        }
        companyName = Driver.of("\(reservation.listingDetails.company.name)")

        if reservation.listingDetails.option == .OpenVoucher {
            dateStatic = Driver.of(NSLocalizedString("redeem_from", comment: ""))

            reservationDate = Driver.of("\(reservation.reservationFromDateTime.RedeemDateString!) until \(reservation.reservationToDateTime.RedeemDateString!) ")

            isListingOpenVouture = Driver.of(true)

        } else {
            dateStatic = Driver.of(NSLocalizedString("redeem_from", comment: ""))

            reservationDate = Driver.of("\(reservation.reservationFromDateTime.time(.HourMinutePeriod)) - \(reservation.reservationToDateTime.time(.HourMinutePeriod)), \(reservation.reservationFromDateTime.RedeemDateString!)")

            isListingOpenVouture = Driver.of(false)
        }

        super.init()
    }

    // MARK:- Life cycle
    deinit {

    }
}
