//
//  CountriesCodesViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  CountriesCodesViewControllerViewModel
 */
final class CountriesCodesViewControllerViewModel: ViewModel {

    //MARK:- Input
    let DoneButtonDidTap = PublishSubject<Void>()
    let selectedCountryCode: Variable<CountryPhoneRepresentation>

    // MARK:- Intermediate

    // MARK:- Output

    // MARK:- Signal
    let doneButtonDidTap = PublishSubject<()>()

    init(
        selectedCountryCode: Variable<CountryPhoneRepresentation>
        ) {
        self.selectedCountryCode = selectedCountryCode
        super.init()

        doneButtonDidTap.subscribeNext { [weak self] _ in
            self?.lightHouseService.navigate.onNext({ (viewController) in
                viewController.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        .addDisposableTo(disposeBag)
    }
}
