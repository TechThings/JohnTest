//
//  AddPaymentMethodTableViewCellViewModel.swift
//  FAVE
//
//  Created by Ranjeet on 23/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alexandria
import CreditCardValidator

/**
 *  @author Ranjeet
 *
 *  AddPaymentMethodTableViewCellViewModel
 */
final class AddPaymentMethodTableViewCellViewModel: ViewModel {

    // MARK:- Constants
    static let MaxCVVNumberOfCharachters = 4
    static let MinCVVNumberOfCharachters = 3

    // MARK:- Dependency
    private let resultSubject: PublishSubject<PaymentMethod?>
    private let creditCardValidator: CreditCardValidator
    private let adyenPayment: AdyenPaymentFacade
    // MARK:- Variable
    private let cardNumber = Variable("")
    private let expiryDate: Variable<NSDate?> = Variable(nil)
    private let cvv = Variable("")
    private let nameValid = Variable(false)
    private let cardNumberValid = Variable(false)
    private let cvvValid = Variable(false)
    private let cardExpiryDateValid = Variable(false)

    //MARK:- Input
    let name = Variable("")
    let tempCardNumber = Variable("")
    let tempCardExpiryDate = Variable("")
    let tempCVV = Variable("")
    let addCardButtonDidTap = PublishSubject<()>()

    // MARK: Output
    let formatedCardNumber: Driver<String>
    var addCardButtonEnabled: Driver<Bool> = Driver.of(false)
    let moveToNextReponserTrigger: Driver<Void>
    let formatedCardExpiryDate: Driver<String>
    let formatedCVV: Driver<String>

    let nameValidated: Driver<Bool>
    let cardNumberValidated: Driver<Bool>
    let cvvNumberValidated: Driver<Bool>
    let expiryDateValidated: Driver<Bool>
    let cardImage: Driver<UIImage?>

    init(resultSubject: PublishSubject<PaymentMethod?>, adyenPayment: AdyenPaymentFacade, creditCardValidator: CreditCardValidator = CreditCardValidator()) {
        self.resultSubject = resultSubject
        self.creditCardValidator = creditCardValidator
        self.adyenPayment = adyenPayment

        cardImage = cardNumber
            .asDriver()
            .map { (cardNumber: String) -> UIImage? in
                guard let cardTypeName = creditCardValidator.typeFromString(cardNumber)?.name else { return nil }

                // CC: Should be an enum
                if cardTypeName == "Visa" {
                    return UIImage(named:"Visa")
                }
                if cardTypeName == "MasterCard" {
                    return UIImage(named:"MasterCard")
                }
                return nil
        }

        nameValidated = nameValid
            .asObservable()
            .skipWhile { (nameValid: Bool) -> Bool in return !nameValid }
            .distinctUntilChanged()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)

        cardNumberValidated = cardNumberValid
            .asObservable()
            .skipWhile { (cardNumberValid: Bool) -> Bool in return !cardNumberValid }
            .distinctUntilChanged()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)

        cvvNumberValidated = cvvValid
            .asObservable()
            .skipWhile { (cvvValid: Bool) -> Bool in return !cvvValid }
            .distinctUntilChanged()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)

        expiryDateValidated = Observable.of(
                cardExpiryDateValid.asObservable().skipWhile { !$0 }
            , tempCardExpiryDate.asObservable().distinctUntilChanged().map { (tempCardExpiryDate: String) -> Bool in return tempCardExpiryDate.characters.count != 5 }.skipWhile { (tempCardExpiryDateValid: Bool) -> Bool in return !tempCardExpiryDateValid }
            )
            .merge()
            .distinctUntilChanged()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)

        formatedCardNumber = tempCardNumber
            .asDriver()
            .map { (cardNumber: String) -> String in
                let result = cardNumber.formattedCardNumber()
                return result
        }

        moveToNextReponserTrigger = Observable.of(
            cardExpiryDateValid.asObservable().distinctUntilChanged().filter { (cardExpiryDateValid: Bool) -> Bool in return cardExpiryDateValid }
            , cardNumberValid.asObservable().distinctUntilChanged().filter { (cardNumberValid: Bool) -> Bool in return cardNumberValid }
            , cvvValid.asObservable().distinctUntilChanged().filter { (cvvValid: Bool) -> Bool in return cvvValid }
            )
            .merge()
            .map { _ -> () in
                return ()
            }
            .asDriver(onErrorJustReturn: ())

        formatedCardExpiryDate = Observable
            .zip(tempCardExpiryDate.asObservable()
                , tempCardExpiryDate.asObservable().skip(1)) { ($0, $1) }
            .map { (lastTempCardExpiryDate, currentTempCardExpiryDate) -> String in
                // Don't exceed 5 characters "MM/YY"
                guard currentTempCardExpiryDate.characters.count <= 5 else {
                    return currentTempCardExpiryDate[0...4]
                }

                // Deleting The "/" automatically when the courser move *back* to it
                if currentTempCardExpiryDate.characters.last == "/" {
                    return currentTempCardExpiryDate[0...1]
                }

                // Add "/" when the month section is complete
                if lastTempCardExpiryDate != currentTempCardExpiryDate && currentTempCardExpiryDate.characters.count >= 2 && currentTempCardExpiryDate.containsString("/") == false {
                    return currentTempCardExpiryDate.insert("/", atIndex: 2)
                }

                return currentTempCardExpiryDate
            }
            .asDriver(onErrorJustReturn: "")

        formatedCVV = tempCVV
            .asDriver()
            .map { (tempCVV: String) -> String in
                guard tempCVV.characters.count <= AddPaymentMethodTableViewCellViewModel.MaxCVVNumberOfCharachters else {
                    let result = tempCVV[0...(AddPaymentMethodTableViewCellViewModel.MaxCVVNumberOfCharachters - 1)]
                    return result
                }
                return tempCVV
        }

        super.init()

        addCardButtonEnabled = Observable.combineLatest(
            cardExpiryDateValid.asObservable().distinctUntilChanged()
            , nameValid.asObservable().distinctUntilChanged()
            , cardNumberValid.asObservable().distinctUntilChanged()
            , cvvValid.asObservable().distinctUntilChanged()
            , activityIndicator.asObservable().distinctUntilChanged()
            , resultSelector: { (cardExpiryDateValid: Bool, nameValid: Bool, cardNumberValid: Bool, cvvValid: Bool, activityIndicator: Bool) -> Bool in
                let results = cardExpiryDateValid && nameValid && cardNumberValid && cvvValid && !activityIndicator
                return results
        })
            .asDriver(onErrorJustReturn: false)

        name
            .asObservable()
            .distinctUntilChanged()
            .map {(name: String) -> Bool in
                let result = name.isNotEmpty
                return result
            }
            .bindTo(nameValid)
            .addDisposableTo(disposeBag)

        tempCardNumber
            .asObservable()
            .distinctUntilChanged()
            .map { (tempCardNumber: String) -> String in
                let result = tempCardNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                return result
            }
            .bindTo(cardNumber)
            .addDisposableTo(disposeBag)

        cardNumber
            .asObservable()
            .distinctUntilChanged()
            .map { (cardNumber: String) -> Bool in
                guard cardNumber.characters.count >= 16 else { return false }
                let result =  creditCardValidator.validateString(cardNumber)
                return result
            }
            .bindTo(cardNumberValid)
            .addDisposableTo(disposeBag)

        addCardButtonDidTap
            .subscribeNext { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.requestAddPaymentMethod()
            }
            .addDisposableTo(disposeBag)

        expiryDate
            .asObservable()
            .map { (date: NSDate?) -> Bool in
                guard let date = date else { return false}
                guard date > NSDate() else { return false}
                return true
            }
            .bindTo(cardExpiryDateValid)
            .addDisposableTo(disposeBag)

        cvv
            .asObservable()
            .distinctUntilChanged()
            .map { (cvv: String) -> Bool in
                let results = cvv.characters.count >= AddPaymentMethodTableViewCellViewModel.MinCVVNumberOfCharachters && cvv.characters.count <= AddPaymentMethodTableViewCellViewModel.MaxCVVNumberOfCharachters
                return results
            }
            .bindTo(cvvValid)
            .addDisposableTo(disposeBag)

        formatedCVV
            .asObservable()
            .distinctUntilChanged()
            .bindTo(cvv)
            .addDisposableTo(disposeBag)

        formatedCardExpiryDate
            .asObservable()
            .map { (formatedCardExpiryDate: String) -> NSDate? in
                guard formatedCardExpiryDate.characters.count == 5 else { return nil } // MM/YY
                guard let years = Int("20" + formatedCardExpiryDate[3...4]) else { return nil }
                guard let months = Int(formatedCardExpiryDate[0...1]) where months <= 12 && months >= 1 else { return nil }
                guard let date = NSDate(year: years, month: months, day: 15) else { return nil }
                return date
            }
            .bindTo(expiryDate)
            .addDisposableTo(disposeBag)
    }

    /// By design, the function must not be called unless the all card information has been varefied
    private func requestAddPaymentMethod() {

        let adyenCardConfiguration = AdyenCardConfiguration(cardHolderName: self.name.value, cardNumber: self.cardNumber.value, cvc: self.cvv.value, expiryDate: self.expiryDate.value!)

        let request = self.adyenPayment.addPaymentMethod(adyenCardConfiguration)
            .doOnError { (error: ErrorType) in
                self.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                })
            }
            .doOn { (event: Event<PaymentMethod?>) in // forward events of this observer to another observer
                self.resultSubject.on(event)
            }
            .trackActivity(self.activityIndicator)
            .trackActivity(self.app.activityIndicator)

        request.subscribeNext { _ in
            self.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                viewController.dismissViewControllerAnimated(true, completion: nil)
            })
        }.addDisposableTo(self.disposeBag)

    }
}
