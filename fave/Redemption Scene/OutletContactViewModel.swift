//
//  OutletContactViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  OutletContactViewModel
 */
final class OutletContactViewModel: ViewModel {

    // MARK:- Dependency
    private let wireframeService: WireframeService

    // MARK:- Input
    let outlet: Outlet
    let getOutletDirectionsButtonDidTap = PublishSubject<Void>()
    let callOutletButtonDidTap = PublishSubject<Void>()

    // MARK- Output
    // Static
    let callOutletStatic = Driver.of(NSLocalizedString("purchase_detail_call_text", comment: ""))
    let getDirectionsStatic = Driver.of(NSLocalizedString("purchase_detail_direction_text", comment: ""))

    init(
        wireframeService: WireframeService = wireframeServiceDefault
        , outlet: Outlet
        ) {
        self.wireframeService = wireframeService
        self.outlet = outlet
        super.init()

        getOutletDirectionsButtonDidTap
            .subscribeNext { [weak self] _ in
                self?.getDirections()
            }.addDisposableTo(disposeBag)

        callOutletButtonDidTap
            .subscribeNext { [weak self] _ in
                self?.callOutlet()
            }.addDisposableTo(disposeBag)

    }

    private func callOutlet() {
        guard let telephone = outlet.telephone, let callURL = NSURL(string: "telprompt://\(telephone)") else {
            wireframeService.alertFor(title: NSLocalizedString("oops", comment: "") + "!", message: NSLocalizedString("outlet_have't_phone", comment: ""), preferredStyle: .Alert, actions: nil)
            return
        }

        UIApplication.sharedApplication().openURL(callURL)
    }

    private func getDirections() {
        var actions = [UIAlertAction]()
        if let appleMapsAction = appleMapsAction() { actions.append(appleMapsAction)}
        if let googleMapsAction = googleMapsAction() { actions.append(googleMapsAction)}
        if let waysMapsAction = waysMapsAction() { actions.append(waysMapsAction)}
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)
        actions.append(cancelAction)
        wireframeService.alertFor(title: "", message: "", preferredStyle: .ActionSheet, actions: actions)
    }

    private func appleMapsAction() -> UIAlertAction? {
        guard let url = NSURL(string: "http://maps.apple.com/?q=\(outlet.location.coordinate.latitude),\(outlet.location.coordinate.longitude)") else { return nil }
        let action = UIAlertAction(title: NSLocalizedString("open_in_maps", comment: ""), style: .Default) { _ in
            UIApplication.sharedApplication().openURL(url)
        }
        return action
    }

    private func googleMapsAction() -> UIAlertAction? {
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
            guard let url = NSURL(string: "comgooglemaps://?q=\(outlet.location.coordinate.latitude),\(outlet.location.coordinate.longitude)&zoom=14") else {
                return nil
            }
            let action = UIAlertAction(title: NSLocalizedString("open_in_google_map", comment: ""), style: .Default) { _ in
                UIApplication.sharedApplication().openURL(url)
            }
            return action
        }
        return nil
    }

    private func waysMapsAction() -> UIAlertAction? {
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "waze://")!) {
            guard let url = NSURL(string: "waze://?ll=\(outlet.location.coordinate.latitude),\(outlet.location.coordinate.longitude)&navigate=yes") else {
                return nil
            }
            let action = UIAlertAction(title: NSLocalizedString("open_in_waze", comment: ""), style: .Default) { _ in
                UIApplication.sharedApplication().openURL(url)
            }
            return action
        }
        return nil
    }

}
