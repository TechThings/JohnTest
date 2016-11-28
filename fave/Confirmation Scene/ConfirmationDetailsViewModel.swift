//
// Created by Michael Cheah on 7/8/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

final class ConfirmationDetailsViewModel: ViewModel {

    enum DetailViewType {
        case Location
        case Date
        case Cancellation_Deadline
    }

    // MARK:- Input
    let listing: ListingType!
    let classSession: ClassSession?

    let label: String
    let details: String

    init(listing: ListingType!,
         classSession: ClassSession?,
         viewType: DetailViewType) {
        self.listing = listing
        self.classSession = classSession

        switch viewType {
        case DetailViewType.Location:
            self.label = NSLocalizedString("partner_detail_location_text", comment: "")
            self.details = self.listing.outlet.name
            break
        case DetailViewType.Date:

            if let voucher = listing as? ListingOpenVoucher {
                self.label = NSLocalizedString("my_fave_redeem_from_text", comment: "")

                if let voucherDetail = voucher.voucherDetail {
                    self.details = voucherDetail.validityStartDateTime.mediumDateString()
                            + " - " + voucherDetail.validityEndDateTime.mediumDateString()
                } else {
                    self.details = ""
                }
            } else {
                self.label = NSLocalizedString("date", comment: "")

                if let session = self.classSession {
                    self.details = session.startDateTime.mediumDateString()
                } else {
                    self.details = ""
                }
            }

            break
        case DetailViewType.Cancellation_Deadline:
            self.label = NSLocalizedString("cancel_before", comment: "")
            if let session = self.classSession,
            displayDateTime = session.earlyCancellationDate.timeslotTimeDateString {
                self.details = displayDateTime
            } else {
                self.details = ""
            }
            break
        }
    }

// MARK:- Life cycle
    deinit {

    }
}
