//
//  ServicePayable.swift
//  FAVE
//
//  Created by Light Dream on 11/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol PaymentFacadeType {

    func reserveOffer(configuration: ReservationConfiguration) -> Observable<Reservation>

    func pay(configuration: PayingConfiguration?) -> Observable<()>
}

extension PaymentFacadeType {
    // convenience method
    func confirmReservationAPIRequestPayload(reservationConfiguration: ReservationConfiguration) -> ConfirmReservationAPIRequestPayload {
        let reservableType: ListingOption = { () -> ListingOption in
            if reservationConfiguration.listingDetails is ListingOpenVoucherType {
                return ListingOption.OpenVoucher
            } else {
                return ListingOption.TimeSlot
            }
        }()

        let reservableId: Int = { () -> Int in
            if let openVoucher = reservationConfiguration.listingDetails as? ListingOpenVoucherType {
                return openVoucher.id
            } else {
                return reservationConfiguration.classSession!.id // If the listing is not ListingOpenVoucherType, then it's ListingTimeSlotType, and the classSession must be provided
            }
        }()

        let reservationCount = reservationConfiguration.currentSlot

        let primaryPaymentGateway = reservationConfiguration.listingDetails.primaryPaymentGateway.rawValue

        let requestPayload = ConfirmReservationAPIRequestPayload(reservableId: reservableId
            , reservableType: reservableType.rawValue
            , reservationCount: reservationCount
            , paymentGateway: primaryPaymentGateway
            , cvc: reservationConfiguration.cvc
        )
        return requestPayload
    }

}
