//
//  Provider.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

class Provider: NSObject {

    let app: AppType
    init(
        app: AppType = appDefault
        ) {
        self.app = app
    }

    /// Track the provider activities
    let activityIndicator = ActivityIndicator()

    let disposeBag = DisposeBag()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
