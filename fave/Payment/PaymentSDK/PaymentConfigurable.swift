//
//  PaymentConfigurable.swift
//  FAVE
//
//  Created by Light Dream on 11/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

/// defines a good common point that can be used for further stricter ruling
protocol PaymentConfigurable {
    var paymentGateway: PaymentGateway { get }
}

protocol PaymentMethodConfigurable: PaymentConfigurable { }

protocol PaymentReserveConfigurable: PaymentConfigurable { }

protocol PaymentPayingConfigurable: PaymentConfigurable { }

struct PayingConfiguration: PaymentPayingConfigurable {

    let reservationSetId: Int
    let totalChargeAmount: Double
    let paymentGatewayType: PaymentGateway
    let reservation: Reservation

    var paymentGateway: PaymentGateway {
        return self.paymentGatewayType
    }

    private init(reservationSetId: Int, totalChargeAmount: Double, paymentGatewayType: PaymentGateway, reservation: Reservation) {
        self.reservationSetId = reservationSetId
        self.totalChargeAmount = totalChargeAmount
        self.paymentGatewayType = paymentGatewayType
        self.reservation = reservation
    }

    // convenience
    static func create(fromReservation reservation: Reservation) -> PayingConfiguration {
        return PayingConfiguration(reservationSetId: reservation.reservationSetId, totalChargeAmount: reservation.listingDetails.purchaseDetails.totalChargeAmount, paymentGatewayType: reservation.listingDetails.primaryPaymentGateway, reservation: reservation)
    }
}

struct AdyenCardConfiguration: PaymentMethodConfigurable {
    let cardHolderName: String
    let cardNumber: String
    let cvc: String
    let expiryDate: NSDate

    var paymentGateway: PaymentGateway {
        return .Adyen
    }

    init(cardHolderName: String, cardNumber: String, cvc: String, expiryDate: NSDate) {
        self.cardHolderName = cardHolderName
        self.cardNumber = cardNumber
        self.cvc = cvc
        self.expiryDate = expiryDate
    }
}

struct ReservationConfiguration: PaymentReserveConfigurable {
    let listingDetails: ListingDetailsType
    let currentSlot: Int
    let classSession: ClassSession?
    let cvc: String?

    var paymentGateway: PaymentGateway {
        return self.listingDetails.primaryPaymentGateway
    }

    init(listingDetails: ListingDetailsType, currentSlot: Int, classSession: ClassSession? = nil, cvc: String? = nil) {
        self.listingDetails = listingDetails
        self.currentSlot = currentSlot
        self.classSession = classSession
        self.cvc = cvc

    }

}

enum Adyen3DSAuthenticationResponse {
    case PaymentMethods(data: [PaymentMethod])
    case ReservationResponse(data: Reservation)
}
