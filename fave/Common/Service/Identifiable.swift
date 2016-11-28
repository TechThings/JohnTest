//
//  Identifiable.swift
//  FAVE
//
//  Created by Nazih Shoura on 09/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol Identifiable {
    associatedtype Identifier: Equatable
    var id: Identifier { get }
}
