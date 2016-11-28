//
//  NextSessionsTimeSlotTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class NextSessionsTimeSlotTableViewCellViewModel: ViewModel {
    let slotText = Variable("")
    let slotHidden = Variable(false)
    let timeText = Variable("")

    init(classSession: ClassSession) {
        super.init()
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
