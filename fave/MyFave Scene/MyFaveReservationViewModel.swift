//
//  MyFaveReservationViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/7/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  MyFaveReservationViewModel State
 */

enum ReservationState {
    case Current
    case Past

    var APIString: String {
        switch self {
        case .Current:
            return "current"
        case .Past:
            return "past"
        }
    }
}

struct MyFaveReservationViewModelState {
    // MARK:- Constant
    let page: Int
    let loadedEverything: Bool
    let state: ReservationState

    init (page: Int, loadedEverything: Bool, state: ReservationState) {
        self.page = page
        self.loadedEverything = loadedEverything
        self.state = state
    }
}

/**
 *  @author Thanh KFit
 *
 *  MyFaveReservationViewModel
 */
class MyFaveReservationViewModel: ViewModel {

    // MARK:- Dependency
    private let reservationsAPI: ReservationsAPI

    // MARK:- State
    let state: Variable<MyFaveReservationViewModelState>

    // MARK:- Constant
    let reservationsPerPage = 25

    // MARK:- Input
    //    let <#Input#>: Variable<<#Input Type#>>

    // MARK:- Intermediate
    //    private let <#Intermediate#>: Driver<<#Intermediate Type#>>

    // MARK- Output
    let currentReservations = Variable([Reservation]())
    let pastReservations = Variable([Reservation]())

    init( reservationsAPI: ReservationsAPI = ReservationsAPIDefault()
        , state: Variable<MyFaveReservationViewModelState>  = Variable(MyFaveReservationViewModelState(page: 0, loadedEverything: false, state: .Current))
        ) {
        self.reservationsAPI = reservationsAPI
        self.state = state
    }

    // MARK:- Life cycle
    deinit {
    }
}

// MARK:- Refreshable
extension MyFaveReservationViewModel: Refreshable {
    func refresh() {
        let requestPayload = ReservationsAPIRequestPayload(filter: state.value.state.APIString, page: state.value.page, limit: reservationsPerPage)

        _ = reservationsAPI.getReservation(withRequestPayload: requestPayload)
            .subscribeNext({ [weak self] in
                self?.currentReservations.value = $0.reservation
                })

        let pastReservationRequest = ReservationsAPIRequestPayload(filter: "past", page: 0, limit: 1)
        _ = reservationsAPI.getReservation(withRequestPayload: pastReservationRequest)
            .subscribeNext({ [weak self] in
                self?.pastReservations.value = $0.reservation
                })
    }
}

// MARK:- Statful
extension MyFaveReservationViewModel: Statful {
    typealias Type = MyFaveReservationViewModelState
}
