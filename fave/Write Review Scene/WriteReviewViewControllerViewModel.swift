//
//  WriteReviewViewControllerViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/12/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  WriteReviewViewControllerViewModel
 */
final class WriteReviewViewControllerViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependence
    private let postReviewAPI: PostReviewAPI

    // MARK:- Output
    let reservation: Variable<Reservation>
    let activityPhoto: Driver<NSURL?>
    let listingName: Driver<String>
    let companyName: Driver<String>
    let outletName: Driver<String>

    let ratingText = Variable<String>("")
    let reviewViewHidden = Variable<Bool>(true)
    let reviewGuideText = Variable<String>("")

    let submitButtonHidden = Variable<Bool>(true)
    let submitButtonActived = Variable<Bool>(false)

    // MARK:- Variable
    let rating = Variable<Float>(0)
    let comment = Variable("")

    init(
        reservation: Reservation
        , postReviewAPI: PostReviewAPI = PostReviewAPIDefault()
        , trackingScreen: TrackingScreen = trackingScreenDefault
        ) {
        self.trackingScreen = trackingScreen
        self.reservation = Variable(reservation)
        self.postReviewAPI = postReviewAPI
        self.activityPhoto = Driver.of(reservation.listingDetails.featuredImage)
        self.listingName = Driver.of(reservation.listingDetails.name)
        self.companyName = Driver.of(reservation.listingDetails.company.name)
        self.outletName = Driver.of(reservation.listingDetails.outlet.name)

        super.init()

        self.rating.asObservable().distinctUntilChanged().subscribeNext({[weak self] value in
            if value > 0 {
                self?.reviewViewHidden.value = false
                self?.submitButtonHidden.value = false
                self?.ratingText.value = String(value)
                self?.reviewGuideText.value =  "Leave a comment here"
            }
        }).addDisposableTo(disposeBag)
    }

    // MARK:- Life cycle
    deinit {

    }

    func didTapSubmit() {
        if rating.value < 3.5 && comment.value.isEmpty {
            self.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                let alertController = UIAlertController.alertController(forTitle: "", message: "Comment can't be blank")
                viewController.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            self.postReview()
        }
    }

    func dismiss() {
        lightHouseService.navigate.onNext { (viewController: UIViewController) in
            viewController.dismissViewControllerAnimated(true, completion: nil)
        }

    }

    func postReview() {
        let requestPayload = PostReviewAPIRequestPayload(reservation_id: reservation.value.id, comment: comment.value, rating: rating.value)

        let response = postReviewAPI
            .postReview(withRequestPayload: requestPayload)
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)

        response.asObservable()
            .subscribeCompleted { [weak self] in
                self?.dismiss()
            }.addDisposableTo(disposeBag)
    }
}
