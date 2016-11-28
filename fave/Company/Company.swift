//
//  Company.swift
//  KFIT
//
//  Created by Nazih Shoura on 14/03/2016.
//  Copyright © 2016 NazihShoura. All rights reserved.
//

import Foundation

enum CompanyType: String {
    case  physical = "physical"
    case  online = "online"
}

extension CompanyType: Defaultable {
    static var defaultValue: CompanyType {
        return .physical
    }
}

final class Company: NSObject, NSCoding {
    let id: Int
    let name: String
    let companyDescription: String?
    let companyType: CompanyType
    let profileIconImageURL: NSURL?
    let featuredImage: NSURL?
    let averageRating: Double
    let ratingCount: Int?
    let outlets: [Outlet]?
    let reviews: [Review]?

    init(id: Int
        , name: String
        , companyDescription: String?
        , companyType: CompanyType
        , profileIconImageURL: NSURL?
        , featuredImage: NSURL?
        , averageRating: Double
        , ratingCount: Int?
        , outlets: [Outlet]?
        , reviews: [Review]) {
        self.id = id
        self.name = name
        self.companyDescription = companyDescription
        self.companyType = companyType
        self.profileIconImageURL = profileIconImageURL
        self.featuredImage = featuredImage
        self.averageRating = averageRating
        self.ratingCount = ratingCount
        self.outlets = outlets
        self.reviews = reviews
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("\(literal.Company).id")
        self.name = aDecoder.decodeObjectForKey("\(literal.Company).name") as! String

        self.companyDescription = aDecoder.decodeObjectForKey("\(literal.Company).companyDescription") as? String

        if let type = aDecoder.decodeObjectForKey("\(literal.Company).companyType") as? String, let  companyType = CompanyType(rawValue : type) {
            self.companyType = companyType
        } else {
            return nil
        }

        self.profileIconImageURL = aDecoder.decodeObjectForKey("\(Company.subjectLabel).profileIconImageURL") as? NSURL

        if aDecoder.containsValueForKey("\(literal.Company).companyDescription") {
            self.featuredImage = aDecoder.decodeObjectForKey("\(literal.Company).featuredImage") as? NSURL
        } else {
            self.featuredImage = nil
        }
        self.averageRating = aDecoder.decodeDoubleForKey("\(Company.subjectLabel).averageRating")
        self.ratingCount = aDecoder.decodeIntegerForKey("\(Company.subjectLabel).ratingCount")

        self.outlets = aDecoder.decodeObjectForKey("\(Company.subjectLabel).outlets") as? [Outlet]

        self.reviews = aDecoder.decodeObjectForKey("\(Company.subjectLabel).reviews") as? [Review]
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: "\(literal.Company).id")
        aCoder.encodeObject(name, forKey: "\(literal.Company).name")
        if let companyDescription = companyDescription {
            aCoder.encodeObject(companyDescription, forKey: "\(literal.Company).companyDescription")
        }
        aCoder.encodeObject(companyType.rawValue, forKey: "\(literal.Company).companyType")
        aCoder.encodeObject(profileIconImageURL, forKey: "\(literal.Company).profileIconImageURL")
        if let featuredImage = featuredImage {
            aCoder.encodeObject(featuredImage, forKey: "\(literal.Company).featuredImage")
        }
        aCoder.encodeDouble(averageRating, forKey: "\(self.subjectLabel).averageRating")
        aCoder.encodeInteger(ratingCount!, forKey: "\(self.subjectLabel).ratingCount")
        aCoder.encodeObject(outlets, forKey: "\(self.subjectLabel).outlets")
        aCoder.encodeObject(reviews, forKey: "\(self.subjectLabel).reviews")
    }
}

extension Company: Serializable {
    typealias Type = Company

    static func serialize(jsonRepresentation: AnyObject?) -> Company? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize (copy from the object being serilized)
        var id: Int?
        var name: String?
        var companyDescription: String?
        var profileIconImageURL: NSURL?
        var featuredImage: NSURL?
        var averageRating: Double?
        var ratingCount: Int?
        var outlets = [Outlet]()
        var reviews = [Review]()

        // Properties initialization
        if let value = json["id"] as? Int {
            id = value
        }

        if let value = json["name"] as? String {
            name = value
        }

        if let value = json["description"] as? String {
            companyDescription = value
        }
        guard let value = json["premise_type"] as? String else { return nil }
        guard let companyType = CompanyType(rawValue : value) else { return nil }

        if let value = json["featured_image"] as? String {
            featuredImage = NSURL(string: value)
        }

        if let value = json["profile_icon_image"] as? String {
            profileIconImageURL = NSURL(string: value)
        }

        if let value = json["average_rating"] as? String {
            averageRating = Double(value)
        }

        if let value = json["average_rating"] as? Double {
            averageRating = value
        }

        if let value = json["rating_count"] as? Int {
            ratingCount = value
        }

        if let value = json["outlets"] as? [AnyObject] {
            for representation in value {
                if let outlet = Outlet.serialize(representation) {
                    outlets.append(outlet)
                }
            }
        }

        if let value = json["reviews"] as? [AnyObject] {
            for representation in value {
                if let review = Review.serialize(representation) {
                    reviews.append(review)
                }
            }
        }

        // Verify properties and initialize object
        if let id = id
            , let name = name
            , let averageRating = averageRating {
            let result = Company(id: id, name: name, companyDescription: companyDescription, companyType: companyType, profileIconImageURL: profileIconImageURL, featuredImage: featuredImage,
                    averageRating: averageRating, ratingCount: ratingCount, outlets: outlets, reviews: reviews)
            return result
        }
        return nil
    }
}
