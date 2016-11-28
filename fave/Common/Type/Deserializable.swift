//
//  Deserializable.swift
//
//  Created by Nazih Shoura on 17/03/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

public protocol Deserializable {
    /**
     Deserialize object to it's JSON representation
     
     - author: Nazih Shoura
     
     - returns: JSON representation of the object it's applied to
     */
    func deserialize() -> [String: AnyObject]
}
