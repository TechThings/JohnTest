//
//  CanceledReservationViewCellViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 14/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CanceledReservationViewCellViewModel: ViewModel {
    let reservation: Reservation
    var message: String = ""
    var title: String = ""
    var icon: UIImage?
    init(reservation: Reservation) {
        self.reservation = reservation
        switch reservation.reservationState {
        case .Cancelled:
            message = NSLocalizedString("purchase_cancelled", comment: "")
            title = NSLocalizedString("cancelled", comment: "")
            icon = UIImage(named: "ic_voucher_cancelled")
        case .ClassCancelled:
            message = NSLocalizedString("purchase_cancelled_by_partner", comment: "")
            title = NSLocalizedString("cancelled", comment: "")
            icon = UIImage(named: "ic_voucher_cancelled")
        case .Expired:
            title = NSLocalizedString("expired", comment: "")
            message = NSLocalizedString("purchase_expired", comment: "")
            icon = UIImage(named: "ic_voucher_expired")
        default: break
        }
    }
}
