//
//  ViewModel.swift
//
//  Created by Nazih Shoura on 03/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import RxSwift
import RxViewModel

class ViewModel: NSObject {
    var disposeBag = DisposeBag()

    private static var activeViewModelUuid: String = NSUUID().UUIDString
    func setAsActive() {
        ViewModel.activeViewModelUuid = self.UUID
    }

    var isActive: Bool {
        return ViewModel.activeViewModelUuid == self.UUID
    }

    let UUID = NSUUID().UUIDString

    let app: AppType
    let lightHouseService: LightHouseService
    let logger: Logger
    init(
        app: AppType = appDefault
        , lightHouseService: LightHouseService = lightHouseServiceDefault
        , logger: Logger = loggerDefault
        ) {
        self.app = app
        self.logger = logger
        self.lightHouseService = lightHouseService
        super.init()
        logger.log("\(String(self)) did init)", loggingMode: .info, logingTags: [.memoryLeaks], shouldShowCodeLocation: false)
    }

    /// Track the ViewModel activities
    let activityIndicator = ActivityIndicator()

    deinit {
        logger.log("\(String(self)) will deinit)", loggingMode: .info, logingTags: [.memoryLeaks], shouldShowCodeLocation: false)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
