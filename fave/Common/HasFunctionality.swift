//
//  HasFunctionality.swift
//  FAVE
//
//  Created by Thanh KFit on 10/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

protocol Functionality {}

protocol HasFunctionality {
    associatedtype Type = Functionality
    var functionality: Type { get }
}
