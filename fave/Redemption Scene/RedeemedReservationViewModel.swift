//
//  RedeemedReservationViewModel.swift
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
 *  RedeemedReservationViewModel
 */
final class RedeemedReservationViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider

    // MARK:- Input
    let reservation: Reservation

    // MARK:- Intermediate

    // MARK- Output

    // Static
    let redemptionCodeStatic: Driver<String> = Driver.of(NSLocalizedString("purchase_detail_redemption_code_text", comment: ""))
    let nameStatic: Driver<String> = Driver.of(NSLocalizedString("name", comment: ""))
    let quantityStatic: Driver<String> = Driver.of(NSLocalizedString("purchase_detail_quantity_text", comment: ""))
    let redeemedOnStatic: Driver<String> = Driver.of(NSLocalizedString("purchase_detail_redeem_on_text", comment: ""))
    let forPartnerRefranceStatic: Driver<String> = Driver.of(NSLocalizedString("purchase_detail_for_partner_reference", comment: ""))

    // Dynamic
    let redemptionCode: Driver<String>
    let redemptionDate: Driver<String>
    let profilePictureViewModel: Driver<AvatarViewModel>
    let quantity: Driver<String>
    let reservationStats: Driver<String>

    init(
        userProvider: UserProvider = userProviderDefault
        , reservation: Reservation
        ) {
        self.reservation = reservation
        self.userProvider = userProvider

        profilePictureViewModel = userProvider
            .currentUser
            .asDriver()
            .map({ (user) -> AvatarViewModel in
                return AvatarViewModel(initial: user.name, profileImageURL: user.profileImageURL)
            })

        quantity = Driver.of(reservation.slotsReserved == 1 ? "1 voucher": "\(reservation.slotsReserved) vouchers")

        redemptionCode = Driver.of(reservation.redemptionCode.uppercaseString)

        if let redeemedAt = reservation.redeemedAt {
            redemptionDate = Driver.of("\(redeemedAt.RedeemDateString!) - \(redeemedAt.time(.HourMinutePeriod))")
        } else {
            redemptionDate = Driver.of("")
        }
        reservationStats = Driver.of("\(reservation.reservationState)")

        super.init()

    }

    // MARK:- Life cycle
    deinit {

    }
}
