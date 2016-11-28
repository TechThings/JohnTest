//
//  OutletCalloutViewModel.swift
//  KFIT
//
//  Created by Nazih Shoura on 17/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OutletCalloutViewModel: ViewModel {
    // Initial
    let partnerName = Variable("")
    let outletName = Variable("")
    let partnerAverageRating: Variable<Double> = Variable(0)
    let partnerRatingCount = Variable(0)
    let partnerReviewCount = Variable(0)
    let partnerProfileImageURL = Variable<NSURL?>(nil)
    let outletDistance = Variable("")
    let distanceHidden: Driver<Bool>

    let outlet: Outlet
    let company: Company!

    init(outlet: Outlet
        , locationService: LocationService = locationServiceDefault
        ) {
        self.outlet = outlet
        self.company = outlet.company
        self.distanceHidden = { () -> Driver<Bool> in
            guard let type = outlet.company?.companyType else { return Driver.of(false) }
            return Driver.of(type == .online)
        }()

        super.init()

        // Success
        partnerName.value = self.company.name
        outletName.value = outlet.name
        if let distance = outlet.distanceKM?.format("0.2") {
            outletDistance.value = ("\(distance) KM")
        }
        partnerAverageRating.value = self.company.averageRating
        partnerProfileImageURL.value = self.company.featuredImage
    }
}
