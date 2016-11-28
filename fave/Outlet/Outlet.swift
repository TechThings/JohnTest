//
//  Outlet.swift
//  KFIT
//
//  Created by Nazih Shoura on 14/03/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import CoreLocation

final class Outlet: NSObject, NSCoding {
    let id: Int
    let name: String
    let town: String?
    let location: CLLocation
    let distanceKM: Double?
    let email: String?
    var favoriteId: Int
    let favoritedCount: Int
    let offersCount: Int
    let address: String?
    let telephone: String?
    let company: Company?

    init(id: Int
        , name: String
        , town: String?
        , location: CLLocation
        , distanceKM: Double?
        , favoriteId: Int
        , email: String?
        , favoritedCount: Int
        , offersCount: Int
        , address: String?
        , telephone: String?
        , company: Company?
        ) {
        self.id = id
        self.name = name
        self.distanceKM = distanceKM
        self.favoriteId = favoriteId
        self.favoritedCount = favoritedCount
        self.offersCount = offersCount
        self.address = address
        self.location = location
        self.town = town
        self.email = email
        self.telephone = telephone
        self.company = company
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("\(Outlet.subjectLabel).id")
        self.favoritedCount = aDecoder.decodeIntegerForKey("\(Outlet.subjectLabel).favoritedCount")
        self.offersCount = aDecoder.decodeIntegerForKey("\(Outlet.subjectLabel).offersCount")
        self.favoriteId = aDecoder.decodeIntegerForKey("\(Outlet.subjectLabel).favoriteId")

        self.town = aDecoder.decodeObjectForKey("\(Outlet.subjectLabel).town") as? String
        self.distanceKM = aDecoder.decodeObjectForKey("\(Outlet.subjectLabel).distanceKM") as? Double
        self.email = aDecoder.decodeObjectForKey("\(Outlet.subjectLabel).email") as? String
        self.address = aDecoder.decodeObjectForKey("\(Outlet.subjectLabel).address") as? String
        self.telephone = aDecoder.decodeObjectForKey("\(Outlet.subjectLabel).telephone") as? String
        self.company = aDecoder.decodeObjectForKey("\(Outlet.subjectLabel).company") as? Company

        guard let location = aDecoder.decodeObjectForKey("\(Outlet.subjectLabel).location") as? CLLocation
            else { return nil }
        self.location = location

        guard let name = aDecoder.decodeObjectForKey("\(Outlet.subjectLabel).name") as? String
            else { return nil }
        self.name = name

        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: "\(self.subjectLabel).id")
        aCoder.encodeInteger(favoritedCount, forKey: "\(self.subjectLabel).favoritedCount")
        aCoder.encodeInteger(offersCount, forKey: "\(self.subjectLabel).offersCount")
        aCoder.encodeInteger(favoriteId, forKey: "\(self.subjectLabel).favoriteId")
        aCoder.encodeObject(name, forKey: "\(self.subjectLabel).name")
        aCoder.encodeObject(town, forKey: "\(self.subjectLabel).town")
        aCoder.encodeObject(location, forKey: "\(self.subjectLabel).location")
        aCoder.encodeObject(distanceKM, forKey: "\(self.subjectLabel).distanceKM")
        aCoder.encodeObject(address, forKey: "\(self.subjectLabel).address")
        aCoder.encodeObject(telephone, forKey: "\(self.subjectLabel).telephone")
        aCoder.encodeObject(company, forKey: "\(self.subjectLabel).company")
    }

    // FIXME: This should be in the ViewModel
    func isFavorited() -> Bool {
        return favoriteId != 0
    }
}

extension Outlet: Serializable {
    final class func serialize(jsonRepresentation: AnyObject?) -> Outlet? {

        guard let json = jsonRepresentation as? [String:AnyObject] else { return nil }

        // Properties initialization
        guard let id = json["id"] as? Int else { return nil }

        guard let name = json["name"] as? String else { return nil }

        let distanceKM = json["distance_in_kms"] as? Double

        guard let favoriteId = json["favorite_id"] as? Int else { return nil }

        guard let favoritedCount = json["favorited_count"] as? Int else { return nil }

        guard let offersCount = json["offers_count"] as? Int else { return nil }

        guard let location = { () -> CLLocation? in
            let value = json["coordinates"] as? String
            return value?.location
            }()
            else {
                return nil
        }

        let town = json["town"] as? String

        let email = json["email"] as? String

        let telephone = json["telephone"] as? String

        let address = json["address"] as? String

        let company = Company.serialize(json["company"])

        // Verify properties and initialize object
        let result = Outlet(id: id, name: name, town: town, location: location, distanceKM: distanceKM, favoriteId: favoriteId, email: email, favoritedCount: favoritedCount, offersCount: offersCount, address: address, telephone: telephone, company: company)

        return result
    }

    override var hashValue: Int {
        return id.hashValue
    }

    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Outlet {
            return object.id == self.id
        } else {
            return false
        }
    }
}

func ==(lhs: Outlet, rhs: Outlet) -> Bool {
    return lhs.id == rhs.id
}
