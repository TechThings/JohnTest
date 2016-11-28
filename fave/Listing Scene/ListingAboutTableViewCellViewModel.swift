//
//  ListingAboutTableViewCellViewModel.swift
//  FAVE
//
//  Created by Gautam on 22/08/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ListingAboutTableViewCellViewModel: ViewModel {

    // MARK:- Input
    var aboutText: Driver<String>
    let readMore: Driver<Bool>

    // MARK- Output
    init(aboutText: String, readMore: Bool) {

        let description: String = aboutText
        let parsedDescription = description.stringByReplacingOccurrencesOfString("\r\n\r\n", withString: "\r\n")
        self.readMore = Driver.of(readMore)
        self.aboutText = Driver.of(parsedDescription)
        super.init()
    }
}
