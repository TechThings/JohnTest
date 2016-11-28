//
//  Defaultable.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol Defaultable {
    associatedtype type
    static var defaultValue: type { get }
}
