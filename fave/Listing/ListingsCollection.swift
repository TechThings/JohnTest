//
//  ListingsCollection.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

class ListingsCollection {

    let id: Int
    let name: String
    let description: String
    let image: NSURL
    let numberOfOffers: Int

    init(
        id: Int
        , name: String
        , description: String
        , image: NSURL
        , numberOfOffers: Int
        ) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.numberOfOffers = numberOfOffers
    }
}

extension ListingsCollection: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ListingsCollection? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize (copy from the object being serilized)
        var id: Int!
        var name: String!
        var description: String!
        var image: NSURL!
        var numberOfOffers: Int!

        // Properties initialization
        if let value = json["id"] as? Int {
            id = value
        }
        if let value = json["name"] as? String {
            name = value
        }
        if let value = json["description"] as? String {
            description = value
        }
        if let value = json["image"] as? String {
            image = NSURL(string:value)
        }
        if let value = json["offers_count"] as? Int {
            numberOfOffers = value
        }

        // Verify properties and initialize object
        if let id = id
            , name = name
            , description = description
            , image = image
            , numberOfOffers = numberOfOffers {
            let result = ListingsCollection(id: id,name: name, description: description, image: image, numberOfOffers: numberOfOffers)
            return result
        }
        return nil
    }
}

extension ListingsCollection: CustomDebugStringConvertible {
    var debugDescription: String { return "id: \(id) name: \(name)" }
}
