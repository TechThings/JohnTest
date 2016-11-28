//
//  ListingBookTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ListingBookTableViewCellViewModel: ViewModel {
    let dateText = Variable("")
    let slotText = Variable("")
    let slotHidden = Variable(false)
    let timeText = Variable("")

    init(listingTimeSlot: ListingTimeSlotType, index: Int) {
        super.init()

        let classSession = listingTimeSlot.classSessions[index]
        if let discoveryDateString = classSession.startDateTime.DiscoveryDateString { dateText.value = discoveryDateString}
        if classSession.remainingSlots <= 1 {
            slotText.value = String(format:NSLocalizedString("slot_count", comment: ""),  classSession.remainingSlots)
        } else {
            slotText.value = String(format:NSLocalizedString("slots_count", comment: ""),  classSession.remainingSlots)
        }
        slotHidden.value = (classSession.remainingSlots > 3)
        timeText.value = ""
        timeText.value = String(format:"%@ - %@", NSString.userVisibleHoursMinutesFromDate(classSession.startDateTime), NSString.userVisibleHoursMinutesFromDate(classSession.endDateTime))
    }
}
