//
//  ConfirmationViewModel.swift
//  fave
//
//  Created by Michael Cheah on 7/8/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

/**
 *  @author Michael Cheah
 *
 *  ConfirmationViewModel
 */

enum ConfirmationItemKind {
    case Title
    case Price
    case Quantity
    case Promo
    case PromoEmpty
    case FinalPrice
    case Credit

    var cellHeight: CGFloat {
        switch self {
        case .Title:
            return UITableViewAutomaticDimension
        case .Promo:
            return 75
        default:
            return 55
        }
    }
}

final class ConfirmationViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let cityProvider: CityProvider
    private let paymentService: PaymentService
    private let confirmReservationAPI: ConfirmReservationAPI
    private let listingAPI: ListingAPI
    private let locationService: LocationService

    // MARK- Input
    let listingDetails: Variable<ListingDetailsType>
    let classSession: ClassSession?
    let currentSlot: Variable<Int>
    let cvc: Variable<String?> = Variable(nil)

    // MARK- Output
    var confirmationItems: [ConfirmationItemKind]
    let minQuantity: Int
    let maxQuantity: Int

    // MARK: Signal
    let reservationButtonDidTap = PublishSubject<()>()

    init(cityProvider: CityProvider = cityProviderDefault
        , userProvider: UserProvider = userProviderDefault
        , listingAPI: ListingAPIDefault = ListingAPIDefault()
        , locationService: LocationService = locationServiceDefault
        , listingDetails: ListingDetailsType
        , classSession: ClassSession?
        , confirmReservationAPI: ConfirmReservationAPI = ConfirmReservationAPIDefault()
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , paymentService: PaymentService = paymentServiceDefault
        ) {
        self.trackingScreen = trackingScreen
        self.paymentService = paymentService

        self.cityProvider = cityProvider
        self.classSession = classSession
        self.confirmReservationAPI = confirmReservationAPI
        self.listingAPI = listingAPI
        self.locationService = locationService

        self.userProvider = userProvider

        self.confirmationItems = [.Title, .Quantity, .Price]

        if listingDetails.purchaseDetails.promoCode != nil {
            self.confirmationItems.append(.Promo)
        } else {
            self.confirmationItems.append(.PromoEmpty)
        }

        if listingDetails.purchaseDetails.creditUsed != nil {
            self.confirmationItems.append(.Credit)
        }

        self.confirmationItems.append(.FinalPrice)

        self.listingDetails = Variable(listingDetails)

        if listingDetails is ListingOpenVoucher {
            let voucherListing = listingDetails as! ListingOpenVoucher
            if let voucherDetail = voucherListing.voucherDetail {
                self.maxQuantity = voucherDetail.purchaseSlots
                self.minQuantity = voucherDetail.purchaseSlots > 0 ? 1 : 0
            } else {
                self.minQuantity = 0
                self.maxQuantity = 0
            }
        } else {
            if classSession != nil {
                self.maxQuantity = classSession!.remainingSlots
                self.minQuantity = classSession!.remainingSlots > 0 ? 1 : 0
            } else {
                self.minQuantity = 0
                self.maxQuantity = 0
            }
        }

        self.currentSlot = Variable(self.minQuantity)

        super.init()

        userProvider
            .currentUser
            .asObservable()
            .skip(1)
            .filter { (user: User) -> Bool in !user.isGuest}
            .subscribeNext { [weak self] _ in
                self?.refresh()
            }.addDisposableTo(disposeBag)

        reservationButtonDidTap
            .subscribeNext { [weak self] _ in
                guard let strongSelf = self else { return }

                let analyticsModel = ConfirmationViewAnalyticsModel(listing: strongSelf.listingDetails.value)
                analyticsModel.confirmReservationClicked.sendToMoEngage()

                if userProvider.currentUser.value.isGuest { strongSelf.signupFlow() } else {
                   strongSelf.reserve()
                }

            }
            .addDisposableTo(disposeBag)

        // TAG: Rangeet
        currentSlot
            .asObservable()
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                return lhs > rhs
            }
            .filter { (currentSlot: Int) -> Bool in
                return currentSlot == 4
            }
            .subscribeNext { [weak self] _ in
                self?.lightHouseService
                    .navigate
                    .onNext({ (viewController) in
                        let alertController = UIAlertController.alertController(forTitle: NSLocalizedString("confirmation_more_than_3_title_text", comment: ""), message: NSLocalizedString("confirmation_more_than_3_description_text", comment: ""))
                        viewController.presentViewController(alertController, animated: true, completion: nil)
                    })
            }
            .addDisposableTo(disposeBag)
    }

    private func signupFlow() {
        lightHouseService
            .navigate
            .onNext { [weak self] (viewController: UIViewController) in
                guard let strongSelf = self else {return}
                let analyticsModel = ConfirmationViewAnalyticsModel(listing: strongSelf.listingDetails.value)
                analyticsModel.confirmReservationClicked.sendToMoEngage()

                let vm = EnterPhoneNumberViewControllerViewModel(enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality.LoginAGuestUser)
                let vc = EnterPhoneNumberViewController.build(vm)
                let nvc = RootNavigationController.build(RootNavigationViewModel())
                nvc.setViewControllers([vc], animated: false)
                viewController.presentViewController(nvc, animated: true, completion: nil)
        }
    }

    func reserve() {
        self.pay()
            .doOnError { [weak self] (error: ErrorType) in
                self?.lightHouseService
                    .navigate
                    .onNext({ (viewController) in
                        let alertController = UIAlertController.alertController(forError: error)
                        viewController.presentViewController(alertController, animated: true, completion: nil)
                    })

                let analyticsModel = ReservationAnalyticsModel(reservation: nil)
                analyticsModel.paymentFailedEvent.send()
            }
            .doOnNext { (reservation: Reservation) in
                let analyticsModel = ReservationAnalyticsModel(reservation: reservation)
                analyticsModel.paymentSuccessEvent?.send()

                // Track Revenue
                // Revenue is a different custom event, different from the regular event on most platforms
                analyticsModel.trackRevenue()
            }
            .subscribeNext { [weak self] (reservation: Reservation) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    guard let rootTabBarController = viewController.presentingViewController as? RootTabBarController else { return }
                    rootTabBarController.selectedIndex = RootTabBarControllerTab.myFave.rawValue
                    guard let myFaveNavigationController = rootTabBarController.selectedViewController as? UINavigationController else { return }
                    guard let myFaveViewController = myFaveNavigationController.topViewController as? MyFaveViewController else { return }
                    myFaveViewController.viewModel.updateViewModel(withState: MyFaveViewModelState(selectedPage: MyFavePage.Reservation))
                    myFaveViewController.refresh()
                    rootTabBarController.nearbyRootNavigationController?.popToRootViewControllerAnimated(true)
                    let redemptionVC = RedemptionViewController.build(RedemptionViewModel(reservationId: reservation.id))
                    myFaveNavigationController.pushViewController(redemptionVC, animated: false)
                    viewController.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            .addDisposableTo(self.disposeBag)
    }

    func pay() -> Observable<Reservation> {
        let configuration = ReservationConfiguration(listingDetails: self.listingDetails.value, currentSlot: self.currentSlot.value, classSession: self.classSession, cvc: self.cvc.value)
        let request = paymentService
            .reserve(withConfiguration: configuration)
            .debug("reserv confirm")
            .trackActivity(self.app.activityIndicator)
            .catchError { [weak self] error -> Observable<Reservation> in

                // make sure you forward the error if it's not CVC

                guard let strongSelf = self else { throw error }

                if let paymentServiceError = error as? PaymentServiceError {
                    if case let .CVCRequired(paymentMethod) = paymentServiceError {
                        return strongSelf.askForCVC(forPaymentMethod: paymentMethod)
                    }
                }
                throw error
            }

        return request

    }

    private func askForCVC(forPaymentMethod paymentMethod: PaymentMethod) -> Observable<Reservation> {

        // after askign for the CVC and making sure we have it, we call confirmAPI
        self.lightHouseService.navigate.onNext { (viewController) in
            let vc = viewController as! ConfirmationViewController
            vc.showCVCView(paymentMethod)
        }

        return self
            .cvc
            .asObservable()
            .skip(1)
            .take(1)
            .filter { cvc in
                if cvc == nil { /// the user cancelled
                    throw ConfirmationViewModelError.PaymentFailed
                }

                return true
            }
            .flatMap { [weak self] _ -> Observable<Reservation> in
                guard let strongerSelf = self else { throw ConfirmationViewModelError.PaymentFailed }
                return strongerSelf.pay() // coz now the cvc will be populated, and it will be sent in the next call
        }

    }
}

// MARK: Helper methods
extension ConfirmationViewModel {
    private var confirmReservationAPIRequestPayload: ConfirmReservationAPIRequestPayload {
        let reservableType: ListingOption = { () -> ListingOption in
            if listingDetails.value is ListingOpenVoucherType {
                return ListingOption.OpenVoucher
            } else {
                return ListingOption.TimeSlot
            }
        }()

        let reservableId: Int = { () -> Int in
            if let openVoucher = listingDetails.value as? ListingOpenVoucherType {
                return openVoucher.id
            } else {
                return classSession!.id // If the listing is not ListingOpenVoucherType, then it's ListingTimeSlotType, and the classSession must be provided
            }
        }()

        let reservationCount = currentSlot.value

        let primaryPaymentGateway = listingDetails.value.primaryPaymentGateway.rawValue

        let requestPayload = ConfirmReservationAPIRequestPayload(reservableId: reservableId
            , reservableType: reservableType.rawValue
            , reservationCount: reservationCount
            , paymentGateway: primaryPaymentGateway
            , cvc: cvc.value
        )
        return requestPayload
    }
}

extension ConfirmationViewModel: Refreshable {
    func refresh() {
        let listingAPIRequestPayload = ListingAPIRequestPayload(listingId: listingDetails.value.id, outletId: listingDetails.value.outlet.id, location: locationService.currentLocation.value)

        _ = listingAPI
            .listing(withRequestPayload: listingAPIRequestPayload)
            .trackActivity(app.activityIndicator)
            .trackActivity(activityIndicator)
            .subscribe(
                onNext: { [weak self] (listingAPIResponsePayload) in
                    self?.listingDetails.value = listingAPIResponsePayload.listingDetails
                    self?.confirmationItems = [.Title, .Quantity, .Price]

                    let listingDetails = listingAPIResponsePayload.listingDetails

                    if listingDetails.purchaseDetails.promoCode != nil {
                        self?.confirmationItems.append(.Promo)
                    } else {
                        self?.confirmationItems.append(.PromoEmpty)
                    }

                    if listingDetails.purchaseDetails.creditUsed != nil {
                        self?.confirmationItems.append(.Credit)
                    }

                    self?.confirmationItems.append(.FinalPrice)

                }, onError: { [weak self] (error) in
                    self?.lightHouseService
                        .navigate
                        .onNext({ (viewController) in
                            let alertController = UIAlertController.alertController(forError: error)
                            viewController.presentViewController(alertController, animated: true, completion: nil)
                        })
                }
            )
            .addDisposableTo(disposeBag)

    }
}

enum ConfirmationViewModelError: DescribableError {
    case PaymentFailed
    case NoPaymentMethod
    case RequiresCVC

    var description: String {
        switch self {
        case .PaymentFailed:
            return "Payment Failed"
        case .NoPaymentMethod:
            return "No Payment Method"
        case .RequiresCVC:
            return "Requires CVC"

        }
    }

    var userVisibleDescription: String {
        switch self {
        case .PaymentFailed:
            return NSLocalizedString("msg_something_wrong", comment: "")
        case .NoPaymentMethod:
            return NSLocalizedString("msg_something_wrong", comment: "")
        case .RequiresCVC:
            return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }
}
