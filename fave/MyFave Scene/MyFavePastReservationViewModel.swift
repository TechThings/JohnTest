//
//  MyFavePastReservationViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/7/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct MyFavePastReservationViewModelState {
    // MARK:- Constant
    let page: Int
    let loadedEverything: Bool
    let state: ReservationsState

    init (page: Int, loadedEverything: Bool, state: ReservationsState) {
        self.page = page
        self.loadedEverything = loadedEverything
        self.state = state
    }
}

/**
 *  @author Thanh KFit
 *
 *  MyFavePastReservationViewModel
 */
final class MyFavePastReservationViewModel: ViewModel {

    // MARK:- Dependency
    private let pastReservationsAPI: PastReservationsAPI

    // MARK:- State
    let state: Variable<MyFavePastReservationViewModelState>

    // MARK:- Constant
    let reservationsPerPage = 25

    // MARK:- Input
    //    let <#Input#>: Variable<<#Input Type#>>

    // MARK:- Intermediate
    //    private let <#Intermediate#>: Driver<<#Intermediate Type#>>

    // MARK- Output
    let reservations = Variable([Reservation]())
    let navigationBarTitle = Variable(NSLocalizedString("past_activities_title_text", comment: ""))

    init( pastReservationsAPI: PastReservationsAPI = PastReservationsAPIDefault()
        , state: Variable<MyFavePastReservationViewModelState>  = Variable(MyFavePastReservationViewModelState(page: 1, loadedEverything: false, state: .Current))
        ) {
        self.pastReservationsAPI = pastReservationsAPI
        self.state = state
    }

    // MARK:- Life cycle
    deinit {
    }
}

// MARK:- Refreshable
extension MyFavePastReservationViewModel: Refreshable {
    func refresh() {

        let pastReservationRequest = PastReservationsAPIRequestPayload(page: state.value.page, limit: reservationsPerPage)
        _ = pastReservationsAPI.getReservation(withRequestPayload: pastReservationRequest).subscribeNext({ [weak self] in
            self?.reservations.value = $0.reservation
        })
    }
}

// MARK:- Statful
extension MyFavePastReservationViewModel: Statful {
    typealias Type = MyFavePastReservationViewModelState
}
