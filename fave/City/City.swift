//
//  City.swift
//  FAVE
//
//  Created by Nazih Shoura on 30/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

final class City: NSObject, NSCoding {

    let id: Int
    let slug: String
    let name: String
    let coordinates: CLLocation
    let country: String
    let shortName: String
    let appLaunched: Bool
    let countryCode: String
    let currency: String
    let blogURL: NSURL

    init(
        id: Int
        , slug: String
        , name: String
        , coordinates: CLLocation
        , country: String
        , shortName: String
        , appLaunched: Bool
        , currency: String
        , countryCode: String
        , blogURL: NSURL
        ) {
        self.id = id
        self.slug = slug
        self.name = name
        self.coordinates = coordinates
        self.country = country
        self.shortName = shortName
        self.appLaunched = appLaunched
        self.currency = currency
        self.countryCode = countryCode
        self.blogURL = blogURL
    }

    required convenience init?(coder decoder: NSCoder) {
        let id = decoder.decodeIntegerForKey("\(literal.City).id")
        let appLaunched = decoder.decodeBoolForKey("\(literal.City).appLaunched")
        guard let slug = decoder.decodeObjectForKey("\(literal.City).slug") as? String
            , let name = decoder.decodeObjectForKey("\(literal.City).name") as? String
            , let coordinates = decoder.decodeObjectForKey("\(literal.City).coordinates") as? CLLocation
            , let currency = decoder.decodeObjectForKey("\(literal.City).currency") as? String
            , let country = decoder.decodeObjectForKey("\(literal.City).country") as? String
            , let shortName = decoder.decodeObjectForKey("\(literal.City).shortName") as? String
            , let countryCode = decoder.decodeObjectForKey("\(literal.City).countryCode") as? String
            , let blogURL = decoder.decodeObjectForKey("\(literal.City).blogURL") as? NSURL
            else { return nil }

        self.init(id: id, slug: slug, name: name, coordinates: coordinates, country: country, shortName: shortName, appLaunched: appLaunched, currency: currency, countryCode: countryCode, blogURL: blogURL)
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(id, forKey: "\(literal.City).id")
        coder.encodeObject(slug, forKey: "\(literal.City).slug")
        coder.encodeObject(name, forKey: "\(literal.City).name")
        coder.encodeObject(coordinates, forKey: "\(literal.City).coordinates")
        coder.encodeBool(appLaunched, forKey: "\(literal.City).appLaunched")
        coder.encodeObject(currency, forKey: "\(literal.City).currency")
        coder.encodeObject(country, forKey: "\(literal.City).country")
        coder.encodeObject(shortName, forKey: "\(literal.City).shortName")
        coder.encodeObject(countryCode, forKey: "\(literal.City).countryCode")
        coder.encodeObject(blogURL, forKey: "\(literal.City).blogURL")
    }
}

extension City: Serializable {
    typealias Type = City

    static func serialize(jsonRepresentation: AnyObject?) -> City? {
        guard let json = jsonRepresentation else {
            return nil
        }

        // Properties to initialize
        var id: Int!
        var slug: String!
        var name: String!
        var coordinates: CLLocation!
        var country: String!
        var shortName: String!
        var appLaunched: Bool!
        var currency: String!
        var countryCode: String!
        var blogURL: NSURL!

        // Properties initialization
        if let value = json["id"] as? Int {
            id = value
        }
        if let value = json["slug"] as? String {
            slug = value
        }
        if let value = json["name"] as? String {
            name = value
        }
        if let value = json["coordinates"] as? String {
            coordinates = value.location
        }
        if let value = json["country"] as? String {
            country = value
        }
        if let value = json["short_name"] as? String {
            shortName = value
        }
        if let value = json["app_launched"] as? Bool {
            appLaunched = value
        }
        if let value = json["currency"] as? String {
            currency = value
        }
        if let value = json["country_code"] as? String {
            countryCode = value
        }
        if let value = json["blog_url"] as? String {
            blogURL = NSURL(string: value)
        }

        // Verify properties and initialize object
        if let id = id
            , slug = slug
            , name = name
            , coordinates = coordinates
            , country = country
            , shortName = shortName
            , appLaunched = appLaunched
            , currency = currency
            , countryCode = countryCode
            , blogURL = blogURL {
            let result = City(
                id: id
                , slug: slug
                , name: name
                , coordinates: coordinates
                , country: country
                , shortName: shortName
                , appLaunched: appLaunched
                , currency: currency
                , countryCode: countryCode
                , blogURL: blogURL
            )
            return result
        }
        return nil
    }
}

func ==(lhs: City, rhs: City) -> Bool {
    return lhs.slug == rhs.slug && lhs.id == rhs.id
}

extension City {
    override var description: String {
        return "slug: \(slug) id: \(id)"
    }
}
