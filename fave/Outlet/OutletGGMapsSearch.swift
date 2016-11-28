//
//  OutletGGMapsSearch.swift
//  FAVE
//
//  Created by Thanh KFit on 6/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import CoreLocation

final class OutletGGMapsSearch: NSObject {
    let id: String
    let name: String
    let vicinity: String
    let photoHeight: Int?
    let photoWidth: Int?
    let photoReference: String?
    let dataJson: [String : AnyObject]

    init(id: String, name: String, vicinity: String, photoHeight: Int?, photoWidth: Int?, photoReference: String?, dataJson: [String : AnyObject]) {
        self.id = id
        self.name = name
        self.vicinity = vicinity
        self.photoHeight = photoHeight
        self.photoWidth = photoWidth
        self.photoReference = photoReference
        self.dataJson = dataJson
    }
}

extension OutletGGMapsSearch : Serializable {
    typealias Type = OutletGGMapsSearch

    static func serialize(jsonRepresentation: AnyObject?) -> OutletGGMapsSearch? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize
        var id: String!
        var name: String!
        var vicinity: String!
        var photoWidth: Int!
        var photoHeight: Int!
        var photoReference: String!
        let dataJson: [String : AnyObject]! = json

        // Properties initialization
        if let value = json["id"] as? String {
            id = value
        }

        if let value = json["name"] as? String {
            name = value
        }

        if let value = json["vicinity"] as? String {
            vicinity = value
        }

        if let value = json["photos"]?[0]?["width"] as? Int {
            photoWidth = value
        }

        if let value = json["photos"]?[0]?["height"] as? Int {
            photoHeight = value
        }

        if let value = json["photos"]?[0]?["photo_reference"] as? String {
            photoReference = value
        }

        if let id = id, name = name, vicinity = vicinity, dataJson = dataJson {

            let result = OutletGGMapsSearch(
                id: id,
                name: name,
                vicinity: vicinity,
                photoHeight: photoHeight,
                photoWidth: photoWidth,
                photoReference: photoReference,
                dataJson: dataJson
            )
            return result
        }
        return nil
    }
}
