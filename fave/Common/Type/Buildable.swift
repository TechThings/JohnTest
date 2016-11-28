//
//  Buildable.swift
//  FAVE
//
//  Created by Nazih Shoura on 03/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol Buildable {
    /// The type of the object to be built
    associatedtype ObjectType

    /// The type of the builder
    associatedtype BuilderType

    /**
     Build object using a builder
     
     - author: Nazih Shoura
     
     - parameter The view model to be usedn in the construction proccess
     
     - returns: The built object
     */
    static func build(builder: BuilderType) -> ObjectType

}

protocol DeepLinkBuildable {
    associatedtype ObjectType
    static func build(deepLink: String, params: [String: AnyObject]?) -> ObjectType?
}
