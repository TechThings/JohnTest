//
//  Statful.swift
//  FAVE
//
//  Created by Nazih Shoura on 03/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

public protocol Statful {
    ///The state type
    associatedtype Type
    var state: Variable<Type> {get}
}
