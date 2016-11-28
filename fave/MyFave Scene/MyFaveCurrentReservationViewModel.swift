//
//  MyFaveCurrentReservationViewModel.swift
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
 *  MyFaveCurrentReservationViewModel State
 */

enum ReservationsState {
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

struct MyFaveCurrentReservationViewModelState {
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
 *  MyFaveCurrentReservationViewModel
 */
final class MyFaveCurrentReservationViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    private let curentReservationsAPI: CurentReservationsAPI

    // MARK:- State
    let state: Variable<MyFaveCurrentReservationViewModelState>

    // MARK:- Constant
    let reservationsPerPage = 25

    let reservations = Variable([Reservation]())
    let isEmptyReservations = Variable(false)
    let numberOfPastReservations = Variable(0)

    init( curentReservationsAPI: CurentReservationsAPI = CurentReservationsAPIDefault()
        , pastReservationsAPI: PastReservationsAPI = PastReservationsAPIDefault()
        , state: Variable<MyFaveCurrentReservationViewModelState>  = Variable(MyFaveCurrentReservationViewModelState(page: 1, loadedEverything: false, state: .Current))
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.curentReservationsAPI = curentReservationsAPI
        self.state = state
        super.init()
        refresh()
    }

}

// MARK:- Refreshable
extension MyFaveCurrentReservationViewModel: Refreshable {
    func refresh() {
        let requestPayload = CurentReservationsAPIRequestPayload(page: state.value.page, limit: reservationsPerPage)
        _ = curentReservationsAPI.getReservation(withRequestPayload: requestPayload).subscribe(
            onNext: { [weak self] in
                self?.reservations.value = $0.reservation
                self?.isEmptyReservations.value = $0.reservation.count == 0
                self?.numberOfPastReservations.value = $0.pastCount
            }, onError: {
                [weak self] _ in
                self?.reservations.value = []
                self?.isEmptyReservations.value = true
            }
        )
    }
}

// MARK:- Statful
extension MyFaveCurrentReservationViewModel: Statful {
    typealias Type = MyFaveCurrentReservationViewModelState
}
