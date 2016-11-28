//
//  Service.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

import RxSwift

class Service {

    let app: AppType
    init(
        app: AppType = appDefault
        ) {
        self.app = app
    }

    /// Track the ViewModel activities
    let networkActivityIndicator = ActivityIndicator()

    let disposeBag = DisposeBag()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
