//
//  OutletsGGMapsSearchCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 6/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class OutletsGGMapsSearchCellViewModel: ViewModel {

    // MARK:- Dependancy
    let addCrowdSourceOutletAPI: AddCrowdSourceOutletAPI

    let profileImageURL = Variable<NSURL?>(nil)
    let partnerName = Variable("")
    let outletName = Variable("")
    let outletGGMapsSearch: OutletGGMapsSearch
    var hasSelectedOnce = false

    init(outletGGMapsSearch: OutletGGMapsSearch
        , addCrowdSourceOutletAPI: AddCrowdSourceOutletAPI = AddCrowdSourceOutletAPIDefault()
        ) {
        self.outletGGMapsSearch = outletGGMapsSearch
        self.addCrowdSourceOutletAPI = addCrowdSourceOutletAPI
        super.init()
        if let width = outletGGMapsSearch.photoWidth, height = outletGGMapsSearch.photoHeight, reference = outletGGMapsSearch.photoReference {
            profileImageURL.value = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?key=\(app.keys.GoogleAPI)&maxwidth=\(width)&maxheight=\(height)&photoreference=\(reference)")
        } else {
            profileImageURL.value = NSURL(string: "")
        }

        partnerName.value = outletGGMapsSearch.name
        outletName.value = outletGGMapsSearch.vicinity
    }

    func addCrowdSourceOutlet() {
        if hasSelectedOnce { return }
        hasSelectedOnce = true
        let addCrowdSourceOutletAPIRequestPayload = AddCrowdSourceOutletAPIRequestPayload(outlet: outletGGMapsSearch)
        addCrowdSourceOutletAPI.addCrowdSourceOutlet (withRequestPayload: addCrowdSourceOutletAPIRequestPayload).subscribe().addDisposableTo(disposeBag)

    }
}
