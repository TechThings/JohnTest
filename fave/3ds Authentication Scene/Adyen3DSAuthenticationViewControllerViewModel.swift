//
//  Adyen3DSAuthenticationViewControllerViewModel.swift
//  FAVE
//
//  Created by Light Dream on 25/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WebKit

final class Adyen3DSAuthenticationViewControllerViewModel: ViewModel {

    // MARK: Dependency
    let adyenData: AdyenAuth3DS
    let provider: Adyen3DSAuthenticationProvider
    // MARK:- Input
    let cancelButtonDidTap: PublishSubject<()> = PublishSubject()

    // MARK: Output
    let result: PublishSubject<Adyen3DSAuthenticationResponse> = PublishSubject()
    let webViewHTMLString: PublishSubject<String> = PublishSubject()

    init(adyenAuthData: AdyenAuth3DS, adyenProvider: Adyen3DSAuthenticationProvider = Adyen3DSAuthenticationProviderDefault()) {
        self.adyenData = adyenAuthData
        self.provider = adyenProvider
        super.init()

        adyenProvider
            .getHTMLString(withData: self.adyenData)
            .subscribe({ (event) in
                self.webViewHTMLString.on(event)
            })
            .addDisposableTo(disposeBag)

        cancelButtonDidTap.subscribeNext { [weak self] _ in
            self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                self?.result.onCompleted()

            }
        }.addDisposableTo(disposeBag)
    }

}
