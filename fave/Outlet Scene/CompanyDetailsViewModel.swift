//
//  CompanyDetailsViewModel.swift
//  FAVE
//
//  Created by Michael Cheah on 7/12/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  CompanyDetailsViewModel
 */

final class CompanyDetailsViewModel: ViewModel {

    // MARK- Output
    let companyName: String
    let companyDetails: String
    let companyProfileIconImage: NSURL?
    let outletName: String
    let featureImage: NSURL?

    let partnerAverageRatingText: String
    let partnerAverageRatingWidth: CGFloat
    let partnerAverageRatingRight: CGFloat
    let partnerAverageRatingFont        = UIFont.systemFontOfSize(12)

    let partnerFavoritedCountText: String
    let partnerFavoritedCountWidth: CGFloat
    let partnerFavoritedCountRight: CGFloat
    let partnerFavoritedCountFont       = UIFont.systemFontOfSize(12)

    let partnerOffersCountText: String
    let partnerOffersCountWidth: CGFloat
    let partnerOffersCountFont          = UIFont.systemFontOfSize(12)

    init(outlet: Outlet,
         company: Company) {

        self.companyName = company.name
        if let companyDetails = company.companyDescription {
            self.companyDetails = companyDetails
        } else {
            self.companyDetails = ""
        }
        self.companyProfileIconImage = company.profileIconImageURL
        self.featureImage = company.featuredImage
        self.outletName = outlet.name

        // Rating, Fave, Offers
        if company.averageRating <= 3.0 {
            partnerAverageRatingWidth = 0
            partnerAverageRatingRight = 0
            partnerAverageRatingText = ""
        } else {
            partnerAverageRatingWidth = 38
            partnerAverageRatingRight = 8
            partnerAverageRatingText = "\(company.averageRating)"
        }

        let favoritedCount = outlet.favoritedCount
        if favoritedCount == 0 {
            partnerFavoritedCountWidth = 0
            partnerFavoritedCountRight = 0
            partnerFavoritedCountText = ""
        } else {
            partnerFavoritedCountRight = 2

            let text = { () -> String in
                if favoritedCount == 1 {
                    return String(format: String(favoritedCount), "",  NSLocalizedString("fave", comment: ""))
                } else {
                    return String(format: String(favoritedCount), "", NSLocalizedString("faves", comment: ""))
                }
            }()

            partnerFavoritedCountWidth = text.widthWithConstrainedHeight(21, font: partnerFavoritedCountFont) + 20
            partnerFavoritedCountText = text
        }

        let offersCount = outlet.offersCount
        if offersCount == 0 {
            partnerOffersCountWidth = 0
            partnerOffersCountText = ""
        } else {

            let text = { () -> String in
                if offersCount == 1 {
                    return "\(offersCount) \((NSLocalizedString("offer", comment: "")))"
                } else {
                    return "\(offersCount) \((NSLocalizedString("partner_detail_offers_text", comment: "")))"
                }
            }()
            partnerOffersCountWidth = text.widthWithConstrainedHeight(21, font: partnerOffersCountFont) + 20
            partnerOffersCountText = text
        }
    }
}
