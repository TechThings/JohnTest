//
//  ListingCancellationTableViewCellViewModel.swift
//  FAVE
//
//  Created by Gautam on 18/08/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ListingCancellationTableViewCellViewModel: ViewModel {

    // MARK:- Input
    var cancellationPolicy: Driver<String>
    var hideCancelPolicy: Driver<Bool>
    var hideFavePromise: Driver<Bool>
    // MARK- Output
    init(cancellationPolicy: String?, showPolicy: Bool, showPromise: Bool) {
        self.hideFavePromise = Driver.of((showPromise == false))
        self.hideCancelPolicy = Driver.of(showPolicy == false)

        if let cancellationPolicy = cancellationPolicy {
            self.cancellationPolicy = Driver.of(cancellationPolicy)
        } else {
            self.cancellationPolicy = Driver.of("")
        }
        super.init()
    }
}
