//
//  OutletGGMapsSearchRequestPayload.swift
//  FAVE
//
//  Created by Thanh KFit on 6/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

final class OutletGGMapsSearchRequestPayload {
    let key: String
    let lat: Double
    let long: Double
    let rankby: String
    let query: String
    let type: [String]

    init (googleAPIKey: String, lat: Double, long: Double, query: String) {
        self.key = googleAPIKey
        self.lat = lat
        self.long = long
        self.rankby = "distance"
        self.query = query
        self.type = ["bakery", "bar", "beauty_salon", "cafe", "florist", "gym", "hair_care", "liquor_store", "meal_delivery", "meal_takeaway", "night_club", "restaurant", "spa"]
    }
}

extension OutletGGMapsSearchRequestPayload: Deserializable {
    func deserialize() -> [String : AnyObject] {
        var parameters = [String : AnyObject]()
        parameters["key"] = key
        parameters["location"] = "\(lat), \(long)"
        parameters["rankby"] = rankby
        parameters["name"] = query
        parameters["type"] = type.joinWithSeparator("|")
        return parameters
    }
}
