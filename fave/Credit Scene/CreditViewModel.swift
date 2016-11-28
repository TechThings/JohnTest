//
//  CreditViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreditViewModel: ViewModel {
    // MARK:- Dependency
    private let userCreditsAPI: UserCreditsAPI
    let wireframeService: WireframeService

    // MARK- Output
    let credit = Variable<UserCredits?>(nil)

    init(
        userCreditsAPI: UserCreditsAPI = UserCreditsAPIDefault()
        , wireframeService: WireframeService = wireframeServiceDefault
        ) {
        self.wireframeService = wireframeService
        self.userCreditsAPI = userCreditsAPI
    }
}

// MARK:- Refreshable
extension CreditViewModel: Refreshable {
    func refresh() {
        userCreditsAPI
            .getBalances(withRequestPayload: UserCreditsAPIRequestPayload())
            .asObservable()
            .trackActivity(app.activityIndicator)
            .subscribeNext { [weak self] (userCreditsAPIResponsePayload: UserCreditsAPIResponsePayload) in
                self?.credit.value = userCreditsAPIResponsePayload.balances
            }.addDisposableTo(disposeBag)
    }
}
