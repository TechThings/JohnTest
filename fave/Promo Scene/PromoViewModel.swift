//
//  PromoViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PromoViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK: Dependancy
    private let promosAPI: PromosAPI
    private let addPromoAPI: AddPromoAPI
    private let wireframeService: WireframeService

    // MARK- Output
    let promos = Variable([Promo]())
    let numberOfPromos = Variable(0)

    init(
        promosAPI: PromosAPI = PromosAPIDefault()
        , addPromoAPI: AddPromoAPI = AddPromoAPIDefault()
        , wireframeService: WireframeService = wireframeServiceDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.promosAPI = promosAPI
        self.addPromoAPI = addPromoAPI
        self.wireframeService = wireframeService
        super.init()
    }

    func addPromoCode(code: String) {
        _ = addPromoAPI.addPromo(withRequestPayload: AddPromoAPIRequestPayload(code: code))
        .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
        .trackActivity(app.activityIndicator)
        .subscribe(
            onNext: { [weak self] in
                if let promos = $0.promos {
                    self?.promos.value = promos
                    let promoAddedViewController = PromoAddedViewController.build(ViewModel())
                    if let promo = (promos.filter {$0.code == code}.first) {
                        promoAddedViewController.promo = promo
                        self?.lightHouseService.navigate.onNext({ (viewController) in
                            viewController.tabBarController?.presentViewController(promoAddedViewController, animated: false, completion: nil)
                        })
                    }

                    // Send Analytics Event
                    let analyticsModel = PromoAnalyticsModel(promoCode: code)
                    analyticsModel.promoAddedEvent.send()
                }
            }, onError: { [weak self] in
                self?.wireframeService.alertFor($0, actions: nil)
            }).addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension PromoViewModel: Refreshable {
    func refresh() {
        promosAPI.promos(withRequestPayload: PromosAPIRequestPayload())
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .trackActivity(app.activityIndicator)
            .subscribe(
                onNext: { [weak self] in
                    self?.promos.value = $0.promos
                }, onError: { [weak self] in
                    self?.wireframeService.alertFor($0, actions: nil)
                }).addDisposableTo(disposeBag)
    }
}
