//
//  Serializable.swift
//
//  Created by Nazih Shoura on 17/03/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

public protocol Serializable {
    ///The type of the object to be serilized
    associatedtype Type

    /**
     Serialize the provided JSON
     
     - author: Nazih Shoura
     
     - parameter jsonRepresentation: json representation of the object
     
     - returns: The serilized object
     */
    static func serialize(jsonRepresentation: AnyObject?) -> Type?
}
