//
//  CountriesCodesTableViewCellModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  CountriesCodesTableViewCellModel
 */
final class CountriesCodesTableViewCellModel: ViewModel {

    // MARK- Signal
    let selectCountryCodeButtonDidTap = PublishSubject<()>()

    // MARK- Output
    let countryName: Driver<String>
    let countryCallingCode: Driver<String>
    let selected: Driver<Bool>

    //MARK:- Input
    let selectedCountryCode: Variable<CountryPhoneRepresentation>

    init(
        countryPhoneRepresentation: CountryPhoneRepresentation
        , selectedCountryCode: Variable<CountryPhoneRepresentation>
        ) {
        self.selectedCountryCode = selectedCountryCode
        self.countryName = Driver.of(countryPhoneRepresentation.countryName)
        self.countryCallingCode = Driver.of("(+"
            .stringByAppendingString(countryPhoneRepresentation.countryCallingCode)
            .stringByAppendingString(")")
        )
        self.selected = selectedCountryCode.asDriver().map { (selectedCountryCode: CountryPhoneRepresentation) -> Bool in selectedCountryCode.countryCode == countryPhoneRepresentation.countryCode }
        super.init()

        selectCountryCodeButtonDidTap
            .subscribeNext { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.selectedCountryCode.value = countryPhoneRepresentation
                strongSelf.lightHouseService.navigate.onNext({ (viewController) in
                    viewController.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            .addDisposableTo(disposeBag)
    }
}
